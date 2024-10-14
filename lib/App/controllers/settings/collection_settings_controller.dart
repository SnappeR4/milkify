// lib/app/controllers/collection_settings_controller.dart
import 'package:get/get.dart';
import '../../data/services/database_helper.dart';

class CollectionSettingsController extends GetxController {
  RxMap<String, Object?> settings = <String, Object?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    settings.value =
        await DatabaseHelper.getSettings(); // Fetch settings from database
  }

  Future<void> updateSetting(String settingColumn, dynamic value) async {
    await DatabaseHelper.saveSettings(
        settingColumn, value); // Save updated settings to database
    settings[settingColumn] = value; // Update the local settings map
  }
}
