import 'package:get/get.dart';
import 'package:milkify/App/data/services/database_helper.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class LanguageSettingsController extends GetxController {
  var selectedLanguage = ''.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Database database;

  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _databaseHelper.database;
    await loadSettings(); // Ensure settings are loaded before continuing
    Get.snackbar("Language", "Work in Progress");
  }

  Future<void> loadSettings() async {
    try {
      Map<String, Object?> settings = await DatabaseHelper.getSettings();
      if (settings.isNotEmpty) {
        selectedLanguage.value = settings['select_language'] as String? ??
            'en'; // Default to 'en' if null
      } else {
        Logger.info("No language setting found, defaulting to 'en'");
        selectedLanguage.value = 'en';
      }
    } catch (e) {
      Logger.error("Error loading settings: $e");
      selectedLanguage.value = 'en'; // Fallback to default in case of error
    }
  }

  Future<void> updateLanguageSetting(String language) async {
    selectedLanguage.value = language; // Update the observable
    try {
      await DatabaseHelper.saveSettings(
          'select_language', language); // Save the language setting
      Logger.info("Language setting updated to $language");
    } catch (e) {
      Logger.error("Error saving settings: $e");
    }
  }
}
