import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../routes/app_routes.dart';
import '../utils/logger.dart';

class SplashController extends GetxController {
  final String dbName = 'milkify.db';
  RxBool isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
    });
    if(await _getStoragePermission()) {
      _checkLoginStatus();
    }
  }

  Future<bool> _getStoragePermission() async {
    bool permissionGranted = false;
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
          permissionGranted = true;
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {
          permissionGranted = false;
      }
    } else {
      if (await Permission.photos.request().isGranted) {
          permissionGranted = true;
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
          permissionGranted = false;
      }
    }
    return permissionGranted;
  }
  void _checkLoginStatus() async {
    backupDatabase("milkify.db");
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? userMobileNumber = prefs.getString('user_mobile_number');
    //
    // if (userMobileNumber == null || userMobileNumber.isEmpty) {
    //   // User is not registered, navigate to RegisterPage
    //   Future.delayed(const Duration(seconds: 5), () {
    //     Get.offAllNamed(AppRoutes.register);
    //   });
    // } else {
      // User is registered, navigate to Dashboard
      Future.delayed(const Duration(seconds: 5), () {
        Get.offAllNamed(AppRoutes.dashboard);
      });
    // }
  }

  Future<void> backupDatabase(String dbName) async {
    try {
      // final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String dbPath = join(await getDatabasesPath(), dbName);
      final File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Logger.error("Database file not found.");
        return;
      }

      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (!await downloadsDirectory.exists()) {
        Logger.error('Download directory does not exist.');
        return;
      }
      // Use external storage for backup
      final String backupFileName = 'milkify_db_bkp_$todayDate.db';
      final File backupFile = File('${downloadsDirectory.path}/$backupFileName');

      // Copy the database file to the backup file path
      await dbFile.copy(backupFile.path);
      Logger.info('Backup created/updated for today: $backupFileName');

      await _manageOldBackups(downloadsDirectory);
    } catch (e) {
      Logger.error('Error during backup: $e');
    }
  }

  Future<void> _manageOldBackups(Directory backupDirectory) async {
    List<FileSystemEntity> backupFiles = backupDirectory.listSync();
    List<File> sortedBackups = backupFiles
        .whereType<File>()
        .where((file) => file.path.contains('milkify_db_bkp_'))
        .toList();

    sortedBackups.sort((a, b) => a.path.compareTo(b.path));

    // Retain only the latest 5 backups
    if (sortedBackups.length > 5) {
      int filesToDelete = sortedBackups.length - 5;
      for (int i = 0; i < filesToDelete; i++) {
        Logger.info("Deleting old backup: ${sortedBackups[i].path}");
        await sortedBackups[i].delete();
      }
    }
  }
}
