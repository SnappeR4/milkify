import 'package:get/get.dart';

import '../../data/services/database_helper.dart';
import '../../utils/logger.dart';
class PrinterSettingsController extends GetxController {
  var isReceiptPrintOn = false.obs;
  var selectedPrinter = ''.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await DatabaseHelper.getSettings();

      if (settings != null && settings.isNotEmpty) {
        // Safely access the properties with null checks
        isReceiptPrintOn.value = settings['receipt_print'] == "true";
        selectedPrinter.value = settings['bluetooth_printer_name'] as String;

        Logger.info("Settings loaded: receipt_print = ${settings['receipt_print']}, bluetooth_printer_name = ${settings['bluetooth_printer_name']}");
      } else {
        Logger.info("No settings found in the database.");
      }
    } catch (e) {
      Logger.error("Error loading settings: $e");
    }
  }

  Future<void> updateSettings() async {
    try {
      String receiptPrintValue = isReceiptPrintOn.value ? "true" : "false";

      // Save settings using the common saveSettings method
      await DatabaseHelper.saveSettings('receipt_print', receiptPrintValue);
      await DatabaseHelper.saveSettings('bluetooth_printer_name', selectedPrinter.value);

      Logger.info("Settings updated successfully.");
      await loadSettings();  // Reload settings to reflect changes
    } catch (e) {
      Logger.error("Error updating settings in the database: $e");
    }
  }

  // Simulated function to list Bluetooth printers
  List<String> getAvailablePrinters() {
    Logger.info("Fetching available Bluetooth printers...");
    // Return a simulated list of printers
    return ["Printer A", "Printer B", "Printer C"];
  }
}
