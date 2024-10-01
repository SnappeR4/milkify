import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../routes/app_routes.dart';
import '../utils/logger.dart';

class SplashController extends GetxController {
  final String dbName = 'milkify.db';
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _requestStoragePermission();
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
    });
  }

  void _checkLoginStatus() async {
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

  // Requesting storage or media-specific permissions for Android 12+
  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid12OrAbove()) {
        // Android 12+ requires media-specific permissions
        await _requestMediaPermissions();
      } else {
        // Request general storage permission for older Android versions
        await _requestLegacyStoragePermission();
      }
    }
  }

  // Check if the Android version is 12 or above
  Future<bool> _isAndroid12OrAbove() async {
    return Platform.isAndroid && (await Permission.storage.status).isDenied && Platform.version.startsWith('12') || Platform.version.startsWith('13') || Platform.version.startsWith('14') || Platform.version.startsWith('15');
  }

  // Request the new media permissions for Android 12+
  Future<void> _requestMediaPermissions() async {
    PermissionStatus imageStatus = await Permission.photos.status;
    PermissionStatus videoStatus = await Permission.videos.status;
    PermissionStatus audioStatus = await Permission.audio.status;

    if (imageStatus.isDenied || videoStatus.isDenied || audioStatus.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio
      ].request();

      if (statuses[Permission.photos]!.isGranted &&
          statuses[Permission.videos]!.isGranted &&
          statuses[Permission.audio]!.isGranted) {
        backupDatabase();
        _checkLoginStatus();
      } else {
        Logger.error("Media permissions denied.", tag: "Splash Screen - Media Permissions Error");
        Get.snackbar(
          "Permission Denied",
          "Media access is required for backup.",
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      backupDatabase();
      _checkLoginStatus();
    }
  }

  // Request legacy storage permission for Android versions below 12
  Future<void> _requestLegacyStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      backupDatabase();
      _checkLoginStatus();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.storage.request();

      if (status.isGranted) {
        backupDatabase();
        _checkLoginStatus();
      } else {
        _checkLoginStatus();
        Logger.error("Storage permission denied.", tag: "Splash Screen - Storage Permission Error");
        Get.snackbar(
          "Permission Denied",
          "Storage access is required for backup.",
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  Future<void> backupDatabase() async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String dbPath = join(await getDatabasesPath(), dbName);
      final File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Logger.error("Database file not found.");
        return;
      }

      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String backupDirectoryPath = join(documentsDirectory.path, 'backups');
      final Directory backupDirectory = Directory(backupDirectoryPath);

      if (!await backupDirectory.exists()) {
        await backupDirectory.create();
      }

      final String backupFileName = 'milkify_db_bkp_$todayDate.db';
      final String backupFilePath = join(backupDirectoryPath, backupFileName);

      await dbFile.copy(backupFilePath);
      Logger.info('Backup created/updated for today: $backupFileName');

      await _manageOldBackups(backupDirectory);
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

    if (sortedBackups.length > 5) {
      int filesToDelete = sortedBackups.length - 5;
      for (int i = 0; i < filesToDelete; i++) {
        Logger.info("Deleting old backup: ${sortedBackups[i].path}");
        await sortedBackups[i].delete();
      }
    }
  }
}
