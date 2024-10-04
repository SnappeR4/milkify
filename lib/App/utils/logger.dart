import 'package:flutter/foundation.dart'; // For kDebugMode

class Logger {
  // General log method
  static void log(String message, {String tag = '', String level = 'LOG'}) {
    if (kDebugMode) {
      final formattedMessage = _formatMessage(message, tag, level);
      print(formattedMessage);
    }
  }

  // Error logging
  static void error(String errorMessage, {String tag = ''}) {
    log(errorMessage, tag: tag, level: 'ERROR');
  }

  // Info logging
  static void info(String infoMessage, {String tag = ''}) {
    log(infoMessage, tag: tag, level: 'INFO');
  }

  static void warn(String warningMessage, {String tag = ''}) {
    log(warningMessage, tag: tag, level: 'WARNING');
  }

  static String _formatMessage(String message, String tag, String level) {
    final tagPart = tag.isNotEmpty ? '[$tag]' : '';
    return '$tagPart [$level] $message';
  }
}
