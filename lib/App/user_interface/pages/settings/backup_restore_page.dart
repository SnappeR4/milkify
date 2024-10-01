// lib/app/pages/backup_restore_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/settings/backup_restore_controller.dart';
import 'package:path/path.dart';

class BackupRestorePage extends StatelessWidget {
  final BackupRestoreController controller = Get.find<BackupRestoreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup and Restore'),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: controller.getBackupFiles(), // Fetch the list of backup files
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final backupFiles = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: backupFiles.length,
                    itemBuilder: (context, index) {
                      final file = backupFiles[index];
                      return ListTile(
                        title: Text(basename(file.path)),
                        subtitle: Text('Backup Date: ${file.statSync().modified}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () {
                            controller.restoreDatabase(file.path).then((_) {
                              // Additional logic if needed
                            }).catchError((error) {
                              Get.snackbar('Error', 'Failed to restore database: $error');
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.backupDatabase().then((_) {
                      Get.snackbar('Success', 'Database backup created successfully');
                    });
                  },
                  child: const Text('Create Backup'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
