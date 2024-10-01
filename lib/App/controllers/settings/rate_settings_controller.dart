import 'package:get/get.dart';
import 'package:milkify/App/data/models/product.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:sqflite/sqflite.dart'; // Assuming you're using Sqflite for database

class RateSettingController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Database db;

  @override
  Future<void> onInit() async {
    super.onInit();
    db = await _database.database;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    // Fetch products from the database
    final List<Map<String, dynamic>> maps = await db.query('product');
    products.value = List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['p_id'],
        name: maps[i]['name'],
        rate: maps[i]['rate'],
      );
    });
  }

  Future<void> updateRate(int productId, double newRate) async {
    await db.update(
      'product',
      {'rate': newRate},
      where: 'p_id = ?',
      whereArgs: [productId],
    );
    fetchProducts(); // Refresh the list after updating
  }
}
