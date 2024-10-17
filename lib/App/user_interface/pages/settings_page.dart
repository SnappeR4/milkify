// lib/app/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 3 / 2,
          ),
          children: [
            _buildSettingCard(
              context,
              'Member Settings',
              Icons.person,
              () => Get.toNamed(
                  AppRoutes.memberList), // Navigate to member settings
            ),
            _buildSettingCard(
              context,
              'Profile Settings',
              Icons.person_outline,
              () => Get.toNamed(
                  AppRoutes.profileSettings), // Navigate to profile settings
            ),
            _buildSettingCard(
              context,
              'Backup and Restore',
              Icons.backup,
              () => Get.toNamed(
                  AppRoutes.backupRestore), // Navigate to backup and restore
            ),
            // _buildSettingCard(
            //   context,
            //   'Language Settings',
            //   Icons.language,
            //   () => Get.toNamed(
            //       AppRoutes.languageSettings), // Navigate to language settings
            // ),
            // _buildSettingCard(
            //   context,
            //   'Printer Settings',
            //   Icons.print,
            //       () => Get.toNamed(AppRoutes.printerSettings), // Navigate to printer settings
            // ),
            _buildSettingCard(
              context,
              'Collection Settings',
              Icons.collections,
              () => Get.toNamed(AppRoutes
                  .collectionSettings), // Navigate to collection settings
            ),
            _buildSettingCard(
              context,
              'Rate Settings',
              Icons.bar_chart,
              () => Get.toNamed(
                  AppRoutes.rateSettings), // Navigate to rate chart settings
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
