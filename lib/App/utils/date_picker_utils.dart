import 'package:flutter/material.dart';

class DatePickerUtils {
  static Future<DateTime?> pickDate(
      BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogBackgroundColor: Colors.white,
            // Set background color to white
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Set primary color (e.g., header)
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
