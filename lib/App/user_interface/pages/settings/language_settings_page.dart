import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/settings/language_settings_controller.dart';

class LanguageSettingsPage extends StatelessWidget {
  final LanguageSettingsController controller = Get.find<LanguageSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language_settings'.tr), // Using translation key for the title
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'select_language'.tr, // Translation key for 'Select Language'
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Use Obx to listen to changes in selectedLanguage
              Obx(() {
                if (controller.selectedLanguage.value.isEmpty) {
                  // If language is not loaded yet, show a loading indicator
                  return Center(child: CircularProgressIndicator());
                }

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedLanguage.value, // Bind the value to selectedLanguage
                    isExpanded: true,
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(
                        alignment: AlignmentDirectional.center,
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        alignment: AlignmentDirectional.center,
                        value: 'hi',
                        child: Text('हिंदी'),
                      ),
                      DropdownMenuItem(
                        alignment: AlignmentDirectional.center,
                        value: 'mr',
                        child: Text('मराठी'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateLanguageSetting(value); // Update the language in the controller
                        Get.updateLocale(Locale(value)); // Update the app locale
                      }
                    },
                    hint: Text(
                      'select_language'.tr, // Hint text
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
