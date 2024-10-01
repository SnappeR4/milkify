// lib/app/bindings/language_settings_binding.dart
import 'package:get/get.dart';

import '../../controllers/settings/language_settings_controller.dart';
class LanguageSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageSettingsController>(() => LanguageSettingsController());
  }
}
