import 'package:get/get.dart';
import 'package:milkify/App/controllers/settings/rate_settings_controller.dart';

class RateSettingsBinding extends Bindings {
  @override
  void dependencies() {
      Get.lazyPut<RateSettingController>(() => RateSettingController());
  }
}
