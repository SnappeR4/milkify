import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'dashboard': 'Dashboard',
          'SETTINGS': 'SETTINGS',
          'SALE': 'SALE',
          'PAYMENT COLLECTION': 'PAYMENT COLLECTION',
          'REPORTS': 'REPORT',
          'welcome': 'Welcome to the Milk Collection App',
          'language_settings': 'Language Settings',
          'select_language': 'Select Language',
          // Add more key-value pairs for English
        },
        'hi_IN': {
          'dashboard': 'डैशबोर्ड',
          'SETTINGS': 'सेटिंग्स',
          'SALE': 'बिक्री',
          'PAYMENT COLLECTION': 'संग्रहण',
          'REPORTS': 'रिपोर्ट',
          'welcome': 'दुग्ध संग्रहण ऐप में आपका स्वागत है',
          'language_settings': 'भाषा सेटिंग्स',
          'select_language': 'भाषा चुनें',
          // Add more key-value pairs for Hindi
        },
        'mr_IN': {
          'dashboard': 'डॅशबोर्ड',
          'SETTINGS': 'सेटिंग्ज',
          'SALE': 'विक्री',
          'PAYMENT COLLECTION': 'संकलन',
          'REPORTS': 'अहवाल',
          'welcome': 'दूध संकलन ॲपमध्ये आपले स्वागत आहे',
          'language_settings': 'भाषा सेटिंग्ज',
          'select_language': 'भाषा निवडा',
          // Add more key-value pairs for Marathi
        }
      };
}
