import 'package:get/get.dart';
import 'package:milkify/App/controllers/collection_controller.dart';
import 'package:milkify/App/controllers/sale_controller.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/services/database_helper.dart';
import '../../utils/logger.dart';

class MemberController extends GetxController {
  // List to store the members
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  // List to store filtered members for the search
  final RxList<Map<String, dynamic>> filteredMembers = <Map<String, dynamic>>[].obs;
  // To hold the search query
  final RxString searchQuery = ''.obs;

  // Member ID
  final RxString newMemberId = ''.obs;

  // Database instance
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;

  // Method to add a member
  Future<void> addMember(Map<String, dynamic> newMember) async {
    Logger.info(newMember.toString());
    await database.insert('members', newMember);
    fetchMembers();
  }

  //for sale page
  var isMemberSelected = false.obs;
  //for payment page
  var isMemberSelectedPayment = false.obs;
  final RxMap<String, dynamic> selectedMember = <String, dynamic>{}.obs;
  final SaleController saleController = Get.find<SaleController>();
  final CollectionController collectionController = Get.find<CollectionController>();
  // Method to select a member
  void selectMember(Map<String, dynamic> member) {
    selectedMember.assignAll(member);
    isMemberSelected.value = true;
    saleController.fetchTransactions();
  }
  Future<void> setMemberSelected(bool selected) async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
    isMemberSelected.value = selected;
  }
  //for payment page
  void selectMemberPayment(Map<String, dynamic> member) {
    selectedMember.assignAll(member);
    isMemberSelectedPayment.value = true;
    collectionController.fetchPayments(member['m_id']);
  }
  Future<void> setMemberSelectedPayment(bool selected) async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    filteredMembers.assignAll(memberList);
    isMemberSelectedPayment.value = selected;
  }
  // Method to edit a member
  Future<void> editMember(Map<String, dynamic> member) async {
    await database.update(
      'members',
      member,
      where: 'm_id = ?',
      whereArgs: [member['m_id']],
    );
    fetchMembers(); // Refresh the member list
  }

  // Fetch members from the database
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

  // Delete a member from the database
  Future<void> deleteMember(String memberId) async {
    await database.delete(
      'members',
      where: 'm_id = ?',
      whereArgs: [memberId],
    );
    fetchMembers(); // Refresh the list after deletion
  }

  // Generate a new member ID
  Future<void> generateNewMemberId() async {
    final List<Map<String, dynamic>> result = await database.query(
      'members',
      columns: ['m_id'],
      orderBy: 'm_id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      int lastId = result.first['m_id'] as int;
      newMemberId.value = (lastId + 1).toString();
    } else {
      newMemberId.value = '1'; // Start from 1 if no members exist
    }
  }

  Future<void> submitTransaction(Map<String, dynamic> member, double liters, double rate, double total) async {
    // var newTransaction = {
    //   'm_id': member['m_id'],
    //   'name': member['name'],
    //   'liters': liters,
    //   'rate': rate,
    //   'total': total,
    // };
    Map<String, dynamic>? lastTransaction = await DatabaseHelper.getLastTransaction();
    int trId = 1;
    // Initialize receipt number
    String newReceiptNo = '001';

    if (lastTransaction != null) {
      trId  = lastTransaction['tr_id'] + 1;

      String lastReceiptNo = lastTransaction['receipt_no'];
      int receiptNumber = int.parse(lastReceiptNo) + 1;

      newReceiptNo = receiptNumber.toString().padLeft(3, '0');
    }

    int pId = 0;
    switch(member['milk_type']) {
      case 'Cow':
        pId = 1;
        break;
      case 'Buffalo':
        pId = 2;
        break;
      case 'Mix':
        pId = 3;
        break;
      default:
        pId = 0;
        break;
    }
    Transactions transaction = Transactions(
      id: trId, // Assuming auto-increment ID
      receiptNo: newReceiptNo, // Example receipt number
      billType: '1',//1 normal 2 edited,3 void, 4 return
      memberId: member['m_id'],
      productId: pId,
      productRate: rate,
      liters: liters,
      addOn: 0.0,
      total: total,
      date: DateTime.now().toIso8601String().split('T')[0], // Current date
      time: DateTime.now().toIso8601String().split('T')[1], // Current time
      timestamp: DateTime.now().toString(),
      editedTimestamp: '',
      paymentMode: '0',
      paymentReceivedFlag: 0,
      memberOpeningBalance: member['c_balance'],
      voidBillFlag: 0,
    );

    await DatabaseHelper.saveTransaction(transaction);
    fetchMembers();
    Logger.info(transaction.toMap().toString());
    Get.snackbar('Success', 'Transaction added successfully');
  }
  // Initialize the controller
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    fetchMembers(); // Fetch members when the controller is initialized
  }
}
