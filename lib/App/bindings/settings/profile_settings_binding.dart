// lib/app/bindings/profile_settings_binding.dart
import 'package:get/get.dart';

import '../../controllers/settings/profile_settings_controller.dart';

class ProfileSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
  }
}
