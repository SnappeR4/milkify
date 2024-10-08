import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ReportController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Database database;
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _databaseHelper.database;
  }

  // Get the current date
  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);  // Format as 'YYYY-MM-DD'
  }

  // Get the sum of liters where void_bill_flag = 0
  Future<String> getCurrentDateSumLiters() async {
    final String currentDate = getCurrentDate();
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT SUM(liters) AS sum_liters FROM transactions
      WHERE date = ? AND void_bill_flag = 0
    ''', [currentDate]);

    double sumLiters = result.first['sum_liters'] ?? 0.0;
    return sumLiters.toString();
  }

  // Get the sum of total where void_bill_flag = 0
  Future<String> getCurrentDateSumTotal() async {
    final String currentDate = getCurrentDate();
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT SUM(total) AS sum_total FROM transactions
      WHERE date = ? AND void_bill_flag = 0
    ''', [currentDate]);

    double sumTotal = result.first['sum_total'] ?? 0.0;
    return sumTotal.toString();
  }

  Future<String> getCurrentDateRecordCount() async {
    final String currentDate = getCurrentDate();
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT COUNT(*) AS record_count FROM member_payment
      WHERE date = ?
    ''', [currentDate]);

    int recordCount = result.first['record_count'] ?? 0;
    return recordCount.toString();
  }

  // Get the sum of paid_amount for the current date from member_payment table
  Future<String> getCurrentDateSumPaidAmount() async {
    final String currentDate = getCurrentDate();
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT SUM(paid_amount) AS sum_paid_amount FROM member_payment
      WHERE date = ?
    ''', [currentDate]);

    double sumPaidAmount = result.first['sum_paid_amount'] ?? 0.0;
    return sumPaidAmount.toString();
  }

  // Get the total count of members from the members table
  Future<String> getTotalMemberCount() async {
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT COUNT(*) AS member_count FROM members
    ''');

    int memberCount = result.first['member_count'] ?? 0;
    return memberCount.toString();
  }

  // Get the sum of liters for all members from the members table
  Future<String> getTotalLitersForMembers() async {
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT SUM(liters) AS sum_liters FROM members
    ''');

    double sumLiters = result.first['sum_liters'] ?? 0.0;
    return sumLiters.toString();
  }

  // Get the count of edited bills
  Future<String> getEditedBillCount() async {
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT COUNT(*) AS edited_count 
      FROM transactions
      WHERE bill_type = 2 AND void_bill_flag = 0
    ''');

    int editedCount = result.first['edited_count'] ?? 0;
    return editedCount.toString();
  }

  // Get the count of deleted bills
  Future<String> getDeletedBillCount() async {
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT COUNT(*) AS deleted_count 
      FROM transactions
      WHERE bill_type = 3
    ''');

    int deletedCount = result.first['deleted_count'] ?? 0;
    return deletedCount.toString();
  }
}
