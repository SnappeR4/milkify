import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:milkify/App/controllers/sms_controller.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/data/models/product.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class SaleController extends GetxController {
  // final SmsController smsController = Get.put(SmsController());
  final searchController = TextEditingController();
  var liters = 0.0.obs;
  TextEditingController litersController = TextEditingController();
  final addOnController = TextEditingController();
  final paymentController = TextEditingController();

  Rx<Member?> selectedMember = Rx<Member?>(null);
  Rx<Product?> selectedProduct = Rx<Product?>(null);

  RxList<Member> allMembers = <Member>[].obs; // List to hold all members
  RxList<Member> filteredMembers = <Member>[].obs; // List to hold filtered members
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Database database;

  var cowMilkRate = 0.0.obs;
  var buffaloMilkRate = 0.0.obs;
  var mixMilkRate = 0.0.obs;
  var transactions = <Transactions>[].obs; // Observable list of Transactions

  // Method to fetch all transactions
  Future<void> fetchTransactions() async {
    transactions.value = await DatabaseHelper.getTransactions();
  }
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _databaseHelper.database;
    fetchMembers(); // Load all members on initialization
    fetchProductRatesFromDB();
    await fetchTransactions();
  }
// Fetch product rates from the database and store them in variables
  Future<void> fetchProductRatesFromDB() async {
    final List<Map<String, dynamic>> products = await database.query('product');
    Logger.info(products.toString());
    for (var product in products) {
      switch (product['name']) {
        case 'Cow':
          cowMilkRate.value = product['rate'];
          break;
        case 'Buffalo':
          buffaloMilkRate.value = product['rate'];
          break;
        case 'Mix':
          mixMilkRate.value = product['rate'];
          break;
        default:
          break;
      }
    }
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

  void updateTransaction(String receiptNo, String date, double newLiters, double productRate, String edited_timestamp) async {
    // Calculate the new total
    double updatedTotal = newLiters * productRate;

    // Update the transaction in the database
    int result = await DatabaseHelper.updateTransaction(receiptNo, date, newLiters, updatedTotal,edited_timestamp);

    if (result > 0) {
      await fetchTransactions();
      // smsController.sendSms(
      //   '+919960416178',
      //   'Hello',
      // );
      Logger.info('update was successful, fetch the updated transactions');
    } else {
      Logger.info('Failed to update transaction');
    }
  }

  static Future<int> deleteTransaction(String receiptNo, String date, String editedTimestamp) async {
    return await DatabaseHelper.deleteTransaction(receiptNo, date, editedTimestamp);
  }

  double calculateTotal() {
    double liters2 = liters.value;
    double rate = selectedProduct.value!.rate;
    double addOn = double.parse(addOnController.text);
    return liters2 * rate + addOn;
  }

  double getRateForMilkType(String milkType) {
    switch (milkType) {
      case 'Cow':
        return cowMilkRate.value;
      case 'Buffalo':
        return buffaloMilkRate.value;
      case 'Mix':
        return mixMilkRate.value;
      default:
        return 0.0;
    }
  }

  void updateLiters() {
    liters.value = double.tryParse(litersController.text) ?? 0.0;
  }
  @override
  void onClose() {
    litersController.dispose();
    super.onClose();
  }
}
