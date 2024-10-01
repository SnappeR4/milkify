
class ConverterUtils {
  /// Converts a string to an integer. Returns [defaultValue] if the conversion fails.
  static int parseStringToInt(String? value, {int defaultValue = 0}) {
    if (value == null) {
      return defaultValue;
    }
    return int.tryParse(value) ?? defaultValue;
  }

  /// Converts an integer to a string. Returns an empty string if the integer is null.
  static String intToString(int? value) {
    return value?.toString() ?? '';
  }
}
