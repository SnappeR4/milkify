import 'dart:ffi';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MemberReportController extends GetxController {
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredMembers = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> selectedMember = <String, dynamic>{}.obs;
  var isMemberSelected = false.obs;
  final RxString searchQuery = ''.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;
  var isPdfGenerated = false.obs;
  var saleTransactions = <Transactions>[].obs; // Observable list of sale transactions
  var paymentTransactions = <MemberPayment>[].obs; // Observable list of payment transactions
  var fromDate = ''.obs; // Observable from date
  var toDate = ''.obs; // Observable to date
  var mId = 0.obs; // Observable member ID
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    fetchMembers();
  }
  void selectMember(Map<String, dynamic> member) {
    setMemberId(member['m_id']);
    DateTime currentDate = DateTime.now();
    fromDate.value = _formatDate(currentDate); // Set current date to 'fromDate'
    toDate.value = _formatDate(currentDate);
    fetchTransactions(); // Fetch transactions on init

    selectedMember.assignAll(member);
    isMemberSelected.value = true;
  }
  Future<void> setMemberSelected(bool selected) async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
    isMemberSelected.value = selected;
  }
  Future<void> fetchMembers() async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    members.assignAll(memberList);
    searchMembers(searchQuery.value); // Apply the search if any
  }
  Future<void> syncMembers() async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
  }
  void searchMembers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // If search query is empty, reset the filtered members list
      filteredMembers.assignAll(members);
    } else {
      filteredMembers.assignAll(
        members.where((member) {
          final name = member['name'].toLowerCase();
          final id = member['m_id'].toString();  // Assuming 'm_id' is an integer or string
          final mobileNumber = member['mobile_number'].toString();

          // Check if the query matches either name, id, or mobile number
          return name.contains(query.toLowerCase()) ||
              id.contains(query) ||
              mobileNumber.contains(query);
        }).toList(),
      );
    }
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    filteredMembers.assignAll(members);
  }

// Function to get the total paid amount for a member within a date range
  Future<double> getTotalPaidAmount(int memberId) async {
    var result = await database.rawQuery(
        'SELECT SUM(paid_amount) as totalPaidAmount FROM member_payment WHERE m_id = ? AND date BETWEEN ? AND ?',
        [memberId, fromDate.value, toDate.value]);

    if (result.isNotEmpty) {
      if(result.first["totalPaidAmount"].toString().isNotEmpty){
        double result1 = double.tryParse(result.first["totalPaidAmount"].toString()) ?? 0.0;
        return result1;
      } else {
        return 0.0;
      }
    }
    return 0.0;
  }

// Function to get the total bill amount for a member within a date range
  Future<double> getTotalBillAmount(int memberId) async {
    var result = await database.rawQuery(
        'SELECT SUM(total) as totalBillAmount FROM transactions WHERE m_id = ? AND date BETWEEN ? AND ?',
        [memberId, fromDate.value, toDate.value]);

    if (result.isNotEmpty) {
      if(result.first["totalBillAmount"].toString().isNotEmpty){
        double result1 = double.tryParse(result.first["totalBillAmount"].toString()) ?? 0.0;
        return result1;
      } else {
        return 0.0;
      }
    }
    return 0.0;
  }


  //pdf data
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to fetch sale transactions based on member ID and date range
  Future<void> fetchSaleTransactions() async {
    final List<Map<String, dynamic>> saleMaps = await database.query(
      'transactions',
      where: 'date BETWEEN ? AND ? AND bill_type != ? AND m_id = ?',
      whereArgs: [fromDate.value, toDate.value, 3, mId.value], // Use member ID
    );

    saleTransactions.value = List.generate(saleMaps.length, (i) {
      return Transactions.fromMap(saleMaps[i]);
    });
  }

  // Function to fetch payment transactions based on member ID and date range
  Future<void> fetchPaymentTransactions() async {
    final List<Map<String, dynamic>> paymentMaps = await database.query(
      'member_payment',
      where: 'date BETWEEN ? AND ? AND m_id = ?',
      whereArgs: [fromDate.value, toDate.value, mId.value], // Use member ID
    );

    paymentTransactions.value = List.generate(paymentMaps.length, (i) {
      return MemberPayment.fromMap(paymentMaps[i]);
    });
  }

  // Combined function to fetch both sale and payment transactions
  Future<void> fetchTransactions() async {
    await fetchSaleTransactions();
    await fetchPaymentTransactions();
  }

  // Set the date range
  void setDateRange(DateTime from, DateTime to) {
    fromDate.value = _formatDate(from); // Format the 'from' date
    toDate.value = _formatDate(to);     // Format the 'to' date
    fetchTransactions(); // Fetch transactions when the date range is set
  }

  // Set the member ID
  void setMemberId(int id) {
    mId.value = id;
    fetchTransactions(); // Fetch transactions when member ID is set
  }
}
