
class ConverterUtils {
  static int parseStringToInt(String? value, {int defaultValue = 0}) {
    if (value == null) {
      return defaultValue;
    }
    return int.tryParse(value) ?? defaultValue;
  }

  static String intToString(int? value) {
    return value?.toString() ?? '';
  }
}
