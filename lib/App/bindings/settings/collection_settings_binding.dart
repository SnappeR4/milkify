// lib/app/bindings/collection_settings_binding.dart
import 'package:get/get.dart';

import '../../controllers/settings/collection_settings_controller.dart';
class CollectionSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectionSettingsController>(() => CollectionSettingsController());
  }
}
