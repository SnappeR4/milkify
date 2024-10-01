// lib/app/bindings/member_settings_binding.dart
import 'package:get/get.dart';

import '../../controllers/settings/member_settings_controller.dart';
class MemberSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberController>(() => MemberController());
  }
}
