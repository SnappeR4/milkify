import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings/printer_settings_controller.dart';
import '../../themes/app_theme.dart';

class PrinterSettingsPage extends StatelessWidget {
  final PrinterSettingsController controller =
      Get.find<PrinterSettingsController>();

  PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Increased padding for a cleaner look
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Receipt Print", style: TextStyle(fontSize: 16)),
                // Added fontSize for better readability
                Flexible(
                  child: Obx(() {
                    return SwitchListTile(
                      value: controller.isReceiptPrintOn.value,
                      onChanged: (bool value) async {
                        controller.isReceiptPrintOn.value = value;
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Add space between the row and next section
            Obx(() {
              return controller.isReceiptPrintOn.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Align dropdown to the start
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select Bluetooth Printer",
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            DropdownButton<String>(
                              value: controller.selectedPrinter.value.isEmpty
                                  ? null
                                  : controller.selectedPrinter.value,
                              items: controller
                                  .getAvailablePrinters()
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedPrinter.value = newValue;
                                }
                              },
                              hint: const Text('Select a Printer'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  //method to connect
                                  if (controller
                                      .selectedPrinter.value.isNotEmpty) {
                                    Get.snackbar(
                                        'Connected', 'Printer connected');
                                  }
                                },
                                child: const Text('Connect'),
                              ),
                            ]),
                      ],
                    )
                  : Container();
            }),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await controller.updateSettings();
                  Get.snackbar(
                      'Success', 'Printer connected and settings saved');
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
