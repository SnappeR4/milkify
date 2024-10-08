import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/sms_controller.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class CollectionController extends GetxController {
  TextEditingController amountController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;
  var payments = <MemberPayment>[].obs;
  final SmsController smsController = Get.put(SmsController());
  RxMap<String, Object?> settings = <String, Object?>{}.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    loadSettings();
  }
  Future<void> loadSettings() async {
    settings.value = await DatabaseHelper.getSettings(); // Fetch settings from database
  }
  Future<void> savePayment({
    required int memberId,
    required double paidAmount,
    required double currentBalance,
    required String mobileNumber,
  }) async {
    // Fetch the last bill number from the database
    final List<Map<String, dynamic>> lastBill = await database.rawQuery(
      'SELECT MAX(bill_no) as last_bill_no FROM member_payment WHERE m_id = ?',
      [memberId],
    );

    // If there are no previous bills, set it to 1; otherwise, increment by 1
    int billNo = (lastBill.isNotEmpty && lastBill[0]['last_bill_no'] != null)
        ? (lastBill[0]['last_bill_no'] as int) + 1
        : 1;

    // Prepare the new payment data
    final payment = MemberPayment(
      billNo: billNo, // New bill number
      memberId: memberId,
      paidAmount: paidAmount,
      currentBalance: currentBalance - paidAmount,
      date: DateTime.now().toIso8601String().split('T')[0], // Only the date
      time: DateTime.now().toIso8601String().split('T')[1], // Only the time
    );

    // Insert payment into the database
    await database.insert(
      'member_payment',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update the member's c_balance by adding the paid amount
    await database.execute('''
    UPDATE members SET c_balance = c_balance + ? WHERE m_id = ?
  ''', [paidAmount, memberId]);

    if (settings['sms_enable']==1) {
      double totalBalance = currentBalance - paidAmount;
      String tot = totalBalance.toString();
      String message = '''Bill No : $billNo\nPaid     : $paidAmount\nC.Balance: $tot''';
      if(mobileNumber.length==10) {
        String phoneNumber = "+91" + mobileNumber;
        smsController.sendSms(
          phoneNumber,
          message,
        );
      }
      Get.snackbar("Payment", smsController.sendingStatus as String);
    }
    // Fetch and update payments (if needed for further processing)
    await fetchPayments(memberId);
  }

  // Fetch recent payments for a particular member
  Future<void> fetchPayments(int memberId) async {
    final List<Map<String, dynamic>> paymentRecords = await database.query(
      'member_payment',
      where: 'm_id = ?',
      whereArgs: [memberId],
    );

    payments.value = paymentRecords.map((map) => MemberPayment.fromMap(map)).toList();
  }

  // Get total remaining balance for a member
  Future<double> getRemainingAmount(int memberId) async {
    final result = await database.rawQuery(
      'SELECT SUM(current_balance) as total_balance FROM member_payment WHERE m_id = ?',
      [memberId],
    );

    if (result.isNotEmpty && result[0]['total_balance'] != null) {
      return result[0]['total_balance'] as double;
    }

    return 0.0;
  }

  // Update payment in the database
  Future<void> updatePayment(MemberPayment payment) async {
    await database.update(
      'member_payment',
      payment.toMap(),
      where: 'bill_no = ?',
      whereArgs: [payment.billNo],
    );
    await fetchPayments(payment.memberId); // Refresh payments after updating
  }

  // Delete payment
  Future<void> deletePayment(int billNo) async {
    await database.delete(
      'member_payment',
      where: 'bill_no = ?',
      whereArgs: [billNo],
    );
  }

  Future<double> getRemainingAmountForMember(String memberId) async {
    double totalTransactionAmount = 0.0;
    double totalPaidAmount = 0.0;

    // Get the sum of the total column in transactions table for the given memberId
    try {
      final List<Map<String, dynamic>> transactionResult = await database.rawQuery(
        'SELECT SUM(total) as total FROM transactions WHERE m_id = ?',
        [memberId],
      );

      if (transactionResult.isNotEmpty && transactionResult[0]['total'] != null) {
        totalTransactionAmount = transactionResult[0]['total'] as double;
      }
    } catch (e) {
      Logger.error('Error fetching total transaction amount: $e');
    }

    // Get the sum of the paid_amount column in member_payment table for the given memberId
    try {
      final List<Map<String, dynamic>> paymentResult = await database.rawQuery(
        'SELECT SUM(paid_amount) as total FROM member_payment WHERE m_id = ?',
        [memberId],
      );

      if (paymentResult.isNotEmpty && paymentResult[0]['total'] != null) {
        totalPaidAmount = paymentResult[0]['total'] as double;
      }
    } catch (e) {
      Logger.error('Error fetching total paid amount: $e');
    }

    // Remaining balance is the total transaction amount minus the total paid amount
    double remainingAmount = totalTransactionAmount - totalPaidAmount;

    return remainingAmount;
  }
}
