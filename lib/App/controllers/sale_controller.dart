import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/data/models/product.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class SaleController extends GetxController {
  final searchController = TextEditingController();
  final litersController = TextEditingController();
  final addOnController = TextEditingController();
  final paymentController = TextEditingController();

  Rx<Member?> selectedMember = Rx<Member?>(null);
  Rx<Product?> selectedProduct = Rx<Product?>(null);

  RxList<Member> allMembers = <Member>[].obs; // List to hold all members
  RxList<Member> filteredMembers = <Member>[].obs; // List to hold filtered members
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Database database;
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _databaseHelper.database;
    fetchMembers(); // Load all members on initialization
  }

  // Fetch all members from the database
  void fetchMembers() async {
    final List<Map<String, dynamic>> memberList = await database.query('members');
    Logger.info(memberList.toString());
    allMembers.assignAll(memberList.map((memberData) => Member.fromMap(memberData)).toList());
  }

  // Function to search members
  void searchMembers(String query) {
    filteredMembers.assignAll(
      allMembers.where((member) {
        final name = member.name.toLowerCase();
        final id = member.id.toString(); // Assuming 'id' is an integer or string
        final mobileNumber = member.mobileNumber.toString();

        return name.contains(query.toLowerCase()) || id.contains(query) || mobileNumber.contains(query);
      }).toList(),
    );
  }

  // Function to handle member selection
  void selectMember(Member member) {
    selectedMember.value = member;

    // Fetch the product based on the member's milk type
    DatabaseHelper.getProductByMilkType(member.milkType).then((product) {
      selectedProduct.value = product;
    });
  }

  // Function to save a transaction
  void saveTransaction() async {
    if (selectedMember.value != null && selectedProduct.value != null) {
      Transactions transaction = Transactions(
        id: 0, // Assuming auto-increment ID
        receiptNo: '001', // Example receipt number
        billType: 'Normal',
        memberId: selectedMember.value!.id,
        productId: selectedProduct.value!.id,
        productRate: selectedProduct.value!.rate,
        liters: double.parse(litersController.text),
        addOn: double.parse(addOnController.text),
        total: calculateTotal(),
        date: DateTime.now().toIso8601String().split('T')[0], // Current date
        time: DateTime.now().toIso8601String().split('T')[1], // Current time
        timestamp: DateTime.now().toString(),
        editedTimestamp: '',
        paymentMode: 'Cash',
        paymentReceivedFlag: 1,
        memberOpeningBalance: selectedMember.value!.currentBalance,
        voidBillFlag: 0,
      );

      await DatabaseHelper.saveTransaction(transaction);
      Get.snackbar('Success', 'Transaction saved successfully.');
    } else {
      Get.snackbar('Error', 'Please select a member and product.');
    }
  }

  double calculateTotal() {
    double liters = double.parse(litersController.text);
    double rate = selectedProduct.value!.rate;
    double addOn = double.parse(addOnController.text);
    return liters * rate + addOn;
  }
}
