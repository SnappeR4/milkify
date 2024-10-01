// lib/app/bindings/printer_settings_binding.dart
import 'package:get/get.dart';

import '../../controllers/settings/printer_settings_controller.dart';

class PrinterSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrinterSettingsController>(() => PrinterSettingsController());
  }
}
