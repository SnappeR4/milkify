// lib/app/pages/collection_settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings/collection_settings_controller.dart';

class CollectionSettingsPage extends StatelessWidget {
  final CollectionSettingsController controller =
      Get.find<CollectionSettingsController>();

  CollectionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        final settings = controller.settings;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SwitchListTile(
              title: const Text('Rate Edit'),
              value: settings['dynamic_rate'] == 1,
              onChanged: (value) {
                controller.updateSetting('dynamic_rate', value ? 1 : 0);
              },
            ),
            SwitchListTile(
              title: const Text('Continue Collection'),
              value: settings['continue_coll'] == 1,
              onChanged: (value) {
                controller.updateSetting('continue_coll', value ? 1 : 0);
              },
            ),
            // SwitchListTile(
            //   title: const Text('Payment Flag'),
            //   value: settings['payment_flag'] == 1,
            //   onChanged: (value) {
            //     controller.updateSetting('payment_flag', value ? 1 : 0);
            //   },
            // ),
            // SwitchListTile(
            //   title: const Text('Add-On Flag'),
            //   value: settings['add_on_flag'] == 1,
            //   onChanged: (value) {
            //     controller.updateSetting('add_on_flag', value ? 1 : 0);
            //   },
            // ),
          ],
        );
      }),
    );
  }
}
