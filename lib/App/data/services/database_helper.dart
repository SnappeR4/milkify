import 'package:milkify/App/data/models/product.dart';
import 'package:milkify/App/data/models/profile_model.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "milkify.db";
  static const _databaseVersion = 1; // Update this number when changing the schema

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        brand_name TEXT,
        mobile_number TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE product (
        p_id INTEGER PRIMARY KEY,
        name TEXT,
        rate REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        m_id INTEGER PRIMARY KEY,
        name TEXT,
        address TEXT,
        mobile_number TEXT,
        recently_paid REAL,
        c_balance REAL,
        milk_type TEXT,
        liters REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE member_payment (
        bill_no INTEGER PRIMARY KEY,
        m_id INTEGER,
        paid_amount REAL,
        current_balance REAL,
        date TEXT,
        time TEXT 
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        manager_password TEXT,
        master_password TEXT,
        select_language TEXT,
        sms_enable INTEGER,
        install_date TEXT,
        payment_flag INTEGER,
        add_on_flag INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        tr_id INTEGER PRIMARY KEY,
        receipt_no TEXT,
        bill_type TEXT,
        m_id INTEGER,
        p_id INTEGER,
        p_rate REAL,
        liters REAL,
        addOn REAL,
        total REAL,
        date TEXT,
        time TEXT,
        timestamp TEXT,
        edited_timestamp TEXT,
        payment_mode TEXT,
        payment_received_flag INTEGER,
        m_opening_balance REAL,
        void_bill_flag INTEGER
      )
    ''');
//default settings
    await db.insert('settings', {
      'manager_password': null,
      'master_password': null,
      'select_language': null,
      'sms_enable': null,
      'install_date': null,
      'payment_flag': null,
      'add_on_flag': null,
    });

//default product entry
// Insert default entries
    await db.execute('''
      INSERT INTO product (p_id, name, rate) VALUES 
      (1, 'Cow', 0.0),
      (2, 'Buffalo', 0.0),
      (3, 'Mix', 0.0)
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Implement schema changes and data migrations here
      // Example:
      // await db.execute('ALTER TABLE profile ADD COLUMN new_column_name TEXT;');
    }
  }
  static Future<Map<String, Object?>> getSettings() async {
      final List<Map<String, Object?>> settingsList = await _database!.query("settings");
      Map<String, Object?> settings = {};

      if (settingsList.isNotEmpty) {
        Logger.info("Settings loaded: ${settingsList.toString()}");

        // Extract key-value pairs directly from the map
        for (var setting in settingsList) {
          setting.forEach((key, value) {
            settings[key] = value;  // Add each key-value pair to the settings map
          });
        }
      } else {
        Logger.info("No settings found in the database.");
      }

      return settings;
  }

  static Future<void> saveSettings(String settingColumn, dynamic value) async {
    // Update the specific column in the single row (row ID = 1)
    await _database!.update(
      'settings',
      {settingColumn: value},
    );
    Logger.info('Settings updated: $settingColumn = $value');
  }

  Future<Profile?> getProfile() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('profile');
    if (result.isNotEmpty) {
      return Profile.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertProfile(Profile profile) async {
    final db = await database;
    await db.insert('profile', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProfile(Profile profile) async {
    final db = await database;
    await db.update('profile', profile.toMap());
  }

  // Get product by milk type
  static Future<Product> getProductByMilkType(String milkType) async {
    final List<Map<String, dynamic>> result = await _database!.query(
      'product',
      where: 'name = ?',
      whereArgs: [milkType],
    );
    return Product.fromMap(result.first);
  }

  // Insert a transaction
  static Future<void> saveTransaction(Transactions transaction) async {
    // Insert transaction into the transactions table
    await _database!.insert('transactions', transaction.toMap());

    // Update the member's c_balance by subtracting the transaction's total amount
    await _database!.execute('''
    UPDATE members SET c_balance = c_balance - ? WHERE m_id = ?
  ''', [transaction.total, transaction.memberId]);
  }

  static Future<Map<String, dynamic>?> getLastTransaction() async {
    // Query to get the last transaction based on the highest id
    final List<Map<String, dynamic>> result = await _database!.query(
      'transactions',
      orderBy: 'tr_id DESC',
      limit: 1,
    );

    // Return null if there are no transactions
    if (result.isEmpty) return null;

    return result.first; // Return the last transaction row
  }

  static Future<List<Transactions>> getTransactions() async {
    final List<Map<String, dynamic>> rawTransactions = await _database!.query(
      'transactions',
      orderBy: 'tr_id DESC',
      limit: 2,
    );
    // Convert to List<Transactions>
    return rawTransactions.map((transactionMap) {
      return Transactions.fromMap(transactionMap);
    }).toList();
  }

  // static Future<int> updateTransaction(String receiptNo, String date, double liters, double total) async {
  //   return await _database!.update(
  //     'transactions',
  //     {
  //       'liters': liters,
  //       'total': total,
  //     },
  //     where: 'receipt_no = ? AND date = ?',
  //     whereArgs: [receiptNo, date],
  //   );
  // }

  static Future<int> updateTransaction(String receiptNo, String date, double liters, double total) async {
    // Fetch the original transaction amount
    List<Map<String, dynamic>> originalTransaction = await _database!.query(
      'transactions',
      columns: ['total', 'm_id'],
      where: 'receipt_no = ? AND date = ?',
      whereArgs: [receiptNo, date],
    );

    if (originalTransaction.isNotEmpty) {
      double oldTotal = originalTransaction.first['total'];
      int mId = originalTransaction.first['m_id'];

      // Update the transaction in the transactions table
      int result = await _database!.update(
        'transactions',
        {
          'liters': liters,
          'total': total,
        },
        where: 'receipt_no = ? AND date = ?',
        whereArgs: [receiptNo, date],
      );

      // Adjust the member's c_balance based on the difference between old and new total
      double difference = oldTotal - total;
      await _database!.execute('''
      UPDATE members SET c_balance = c_balance + ? WHERE m_id = ?
    ''', [difference, mId]);

      return result;
    } else {
      // Handle the case where the transaction doesn't exist (return an error code, etc.)
      return 0;
    }
  }

// Add methods to interact with the database
// For example, insert, update, delete operations.
//demo access in controllers
//   import 'package:your_app_name/app/helpers/database_helper.dart';
//
//   class SocietyDetailsController extends GetxController {
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//
//   Future<void> addSocietyDetail(Map<String, dynamic> societyDetail) async {
//   final db = await _dbHelper.database;
//   await db.insert('society_details', societyDetail);
//   }
//
//   Future<List<Map<String, dynamic>>> getSocietyDetails() async {
//   final db = await _dbHelper.database;
//   return await db.query('society_details');
//   }
//   }

}
