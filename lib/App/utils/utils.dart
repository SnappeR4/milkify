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

  static String convertDateFormat(String? date) {
    if (date == null || date.length != 10) {
      return ''; // Return empty string for invalid format
    }

    // Split the date into components
    List<String> parts = date.split('-');
    if (parts.length != 3) {
      return ''; // Return empty string if date does not have 3 parts
    }

    // Reformat from yyyy-mm-dd to dd-mm-yy
    String year = parts[0]; // yyyy
    String month = parts[1]; // mm
    String day = parts[2]; // dd

    // Convert year to 2 digits
    String shortYear = year.substring(2); // Get last two digits of the year

    return '$day-$month-$shortYear';
  }
}
