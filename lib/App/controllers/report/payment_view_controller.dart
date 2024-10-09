import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart'; // Ensure you have sqflite for database operations

class PaymentViewController extends GetxController {
  var paymentTransactions = <MemberPayment>[].obs; // Observable list of transactions
  var fromDate = ''.obs; // Observable from date
  var toDate = ''.obs; // Observable to date
  var isPdfGenerated = false.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;
  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    DateTime currentDate = DateTime.now();
    fromDate.value = _formatDate(currentDate); // Set current date to 'fromDate'
    toDate.value = _formatDate(currentDate);
    fetchTransactions();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to fetch transactions from the database
  Future<void> fetchTransactions() async {
    // Ensure date range is correctly formatted before querying
    final List<Map<String, dynamic>> maps = await database.query(
      'member_payment',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [fromDate.value, toDate.value], // 'yyyy-MM-dd' formatted dates
    );

    paymentTransactions.value = List.generate(maps.length, (i) {
      return MemberPayment.fromMap(maps[i]);
    });
  }

  // Set the date range
  void setDateRange(DateTime from, DateTime to) {
    fromDate.value = _formatDate(from); // Format the 'from' date
    toDate.value = _formatDate(to);     // Format the 'to' date
    fetchTransactions(); // Fetch transactions when the date range is set
  }
}
