// lib/app/controllers/backup_restore_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/routes/app_routes.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupRestoreController extends GetxController {
  final String dbName = 'milkify.db';

  Future<void> backupDatabase() async {
    try {
      final String dbPath = join(await getDatabasesPath(), dbName);
      final File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Logger.error("Database file not found.");
        return;
      }

      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final Directory externalDirectory = Directory('/storage/emulated/0/Download');
      if (!await externalDirectory.exists()) {
        Logger.error('Download directory does not exist.');
        return;
      }

      final String backupFileName = 'milkify_db_bkp_$todayDate.db';
      final String backupFilePath = join(externalDirectory.path, backupFileName);

      // Copy the database file to the backup file path
      await dbFile.copy(backupFilePath);
      Logger.info('Backup created/updated for today: $backupFilePath');
      Get.back();
    } catch (e) {
      Logger.error('Error during backup: $e');
    }
  }

  Future<void> restoreDatabase(String backupFilePath) async {
    // Ask for user confirmation before proceeding
    final bool confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Restore'),
        content: const Text('Are you sure you want to restore the database? This will replace the current database.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), // User cancels
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true), // User confirms
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false; // Default to false if dialog is dismissed

    if (!confirmed) {
      Logger.info('Database restore canceled by user.');
      return; // Exit the method if the user cancels
    }

    try {
      final String dbPath = join(await getDatabasesPath(), dbName);
      final File dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete(); // Delete current database if it exists
      }

      final File backupFile = File(backupFilePath);
      if (await backupFile.exists()) {
        await backupFile.copy(dbPath); // Restore from backup
        Logger.info('Database restored from: $backupFilePath');

        // Notify the user and restart the app
        Get.snackbar(
          'Success',
          'Database restored successfully. The app will restart.',
          snackPosition: SnackPosition.TOP,
        );

        // Restart the app after a short delay to allow the user to read the message
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed(AppRoutes.splash); // Change this to your initial route
        });
      } else {
        Logger.error('Backup file does not exist: $backupFilePath');
        Get.snackbar(
          'Error',
          'Backup file does not exist.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Logger.error('Error during restore: $e');
      Get.snackbar(
        'Error',
        'Failed to restore database: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<List<FileSystemEntity>> getBackupFiles() async {
    final Directory externalDirectory = Directory('/storage/emulated/0/Download');

    if (!await externalDirectory.exists()) {
      Logger.error('Download directory does not exist.');
      return []; // Return empty list if directory does not exist
    }

    // Filter files that contain "milkify_db_bkp" in their name
    final List<FileSystemEntity> backupFiles = externalDirectory
        .listSync()
        .where((file) => file is File && basename(file.path).contains('milkify_db_bkp'))
        .toList();

    if (backupFiles.isEmpty) {
      Logger.info('No backup files found.');
    } else {
      Logger.info('Found ${backupFiles.length} backup files.');
    }

    return backupFiles; // Return list of matching backup files
  }
}
