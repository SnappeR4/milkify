import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/controllers/collection_controller.dart';
import 'package:milkify/App/controllers/sale_controller.dart';
// import 'package:milkify/App/controllers/sms_controller.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/data/services/member_service.dart';
import 'package:milkify/App/user_interface/themes/app_theme.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/services/database_helper.dart';
import '../../utils/logger.dart';

class MemberController extends GetxController {
  final MembersService membersService = MembersService();
  // final SmsController smsController = Get.put(SmsController());
  RxMap<String, Object?> settings = <String, Object?>{}.obs;

  // List to store the members
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;

  // List to store filtered members for the search
  final RxList<Map<String, dynamic>> filteredMembers =
      <Map<String, dynamic>>[].obs;

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
  final RxMap<String, dynamic> selectedMemberPayment = <String, dynamic>{}.obs;
  final SaleController saleController = Get.find<SaleController>();
  final CollectionController collectionController =
      Get.find<CollectionController>();

  void selectMember(Map<String, dynamic> member) async {
    selectedMember.assignAll(member);
    isMemberSelected.value = true;
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Map<String, dynamic>> result = await database.query(
      'transactions', // Your table name
      where: 'm_id = ? AND date = ?', // The condition for querying
      whereArgs: [
        member['m_id'],
        currentDate
      ], // Arguments to replace the placeholders
    );
    // Get current date in the required format

    // Check if transaction exists for the member (assuming you have a fetchTransactionByDateAndMember method)
    bool isTransactionExist = result.isNotEmpty;

    if (isTransactionExist) {
      Get.defaultDialog(
        title: "Transaction Exists",
        middleText:
            "A transaction for this member has already been made today. Do you want to continue?",
        backgroundColor: AppTheme.color1,
        // Set background color to white
        textCancel: "Cancel",
        textConfirm: "Continue",
        onCancel: () {
          isMemberSelected.value = false; // Deselect member if canceled
        },
        onConfirm: () {
          saleController.fetchTransactions(); // Continue if confirmed
          Get.back(); // Close dialog
        },
        cancelTextColor: AppTheme.color7,
        confirmTextColor: AppTheme.color1,
        // Optional: set text color for confirm button
        buttonColor: AppTheme.color2,
        // Set button color based on theme
        barrierDismissible: false, // Make it mandatory to choose an option
      );
    } else {
      // If no transaction exists, proceed as usual
      saleController.fetchTransactions();
    }
  }

  Future<void> setMemberSelected(bool selected) async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    filteredMembers.assignAll(memberList);
    isMemberSelected.value = selected;
  }

  //for payment page
  void selectMemberPayment(Map<String, dynamic> member) {
    selectedMemberPayment.assignAll(member);
    isMemberSelectedPayment.value = true;
    collectionController.fetchPayments(member['m_id']);
  }

  Future<void> setMemberSelectedPayment(bool selected) async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
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
    Get.snackbar("Member", "Member Update Success");
    fetchMembers(); // Refresh the member list
  }

  // Fetch members from the database
  Future<void> fetchMembers() async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    members.assignAll(memberList);
    searchMembers(searchQuery.value); // Apply the search if any
  }

  Future<void> syncMembers() async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
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
          final id = member['m_id']
              .toString(); // Assuming 'm_id' is an integer or string
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
  Future<void> deleteMember(int memberId) async {
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

  Future<void> submitTransaction(Map<String, dynamic> member, double liters,
      double rate, double total) async {
    // var newTransaction = {
    //   'm_id': member['m_id'],
    //   'name': member['name'],
    //   'liters': liters,
    //   'rate': rate,
    //   'total': total,
    // };
    Map<String, dynamic>? lastTransaction =
        await DatabaseHelper.getLastTransaction();
    int trId = 1;
    // Initialize receipt number
    String newReceiptNo = '001';

    if (lastTransaction != null) {
      trId = lastTransaction['tr_id'] + 1;

      String lastReceiptNo = lastTransaction['receipt_no'];
      int receiptNumber = int.parse(lastReceiptNo) + 1;

      newReceiptNo = receiptNumber.toString().padLeft(3, '0');
    }

    int pId = 0;
    switch (member['milk_type']) {
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
      id: trId,
      // Assuming auto-increment ID
      receiptNo: newReceiptNo,
      // Example receipt number
      billType: '1',
      //1 normal 2 edited,3 void, 4 return
      memberId: member['m_id'],
      productId: pId,
      productRate: rate,
      liters: liters,
      addOn: 0.0,
      total: total,
      date: DateTime.now().toIso8601String().split('T')[0],
      // Current date
      time: DateTime.now().toIso8601String().split('T')[1],
      // Current time
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

    if (settings['sms_enable'] == 1) {
      // String totalBalance = (member['c_balance'] + total).toString();
      // String message =
      //     '''Receipt No: $newReceiptNo\nMilk Type : ${member['milk_type']}\nLiters    : $liters\nRate      : $rate\nTotal     : $total\nC.Balance : $totalBalance''';
      if (member["mobile_number"].toString().length == 10) {
        // String phoneNumber = "+91$member['mobile_number']";
        // smsController.sendSms(
        //   phoneNumber,
        //   message,
        // );
        // Get.snackbar("Payment", smsController.sendingStatus as String);
      }
    } else {
      Get.snackbar('Success', 'Transaction Saved successfully');
    }
  }

  Future<void> loadSettings() async {
    settings.value =
        await DatabaseHelper.getSettings(); // Fetch settings from database
  }

  Future<void> importMembers() async {
    List<Member>? importedMembers = await membersService.importMembers();
    if (importedMembers != null) {
      // Delete all members from the database before inserting new ones
      await deleteAllMembers();

      // Insert imported members into the database
      for (var member in importedMembers) {
        if (member.id > 0) {
          await insertMemberIntoDatabase(member);
        }
      }
      Get.snackbar("Member File", "Imported Successfully");
      await fetchMembers();
    }
  }

  // Method to delete all members from the database
  Future<void> deleteAllMembers() async {
    await database.delete('members');
  }

  // Method to insert a member into the database
  Future<void> insertMemberIntoDatabase(Member member) async {
    Map<String, dynamic> memberData = {
      'm_id': member.id,
      'name': member.name,
      'address': member.address,
      'mobile_number': member.mobileNumber,
      'recently_paid': member.recentlyPaid,
      'c_balance': member.currentBalance,
      'milk_type': member.milkType,
      'liters': member.liters,
    };

    // Insert the member into the database
    await database.insert(
      'members', // Name of the table
      memberData,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if already exists
    );
  }

  Future<void> exportMembers() async {
    try {
      // Convert RxList<Map<String, dynamic>> to List<Member>
      List<Member> membersList = members
          .map((member) => Member(
                id: member['m_id'],
                name: member['name'],
                address: member['address'],
                mobileNumber: member['mobile_number'],
                recentlyPaid: member['recently_paid'],
                currentBalance: member['c_balance'],
                milkType: member['milk_type'],
                liters: member['liters'],
              ))
          .toList();

      // Export members to Excel
      String response = await membersService.exportMembers(membersList);
      Get.snackbar("Member File", response);
    } catch (e) {
      Logger.error('Error exporting members: $e');
    }
  }

  // Initialize the controller
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    fetchMembers();
    loadSettings();
  }
}
