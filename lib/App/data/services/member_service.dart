import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/utils/logger.dart';
import 'package:milkify/App/utils/utils.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class MembersService {
  Future<List<Member>?> importMembers() async {
    if (await _requestPermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // Assuming the first sheet contains the members' data
        var sheet = excel.tables[excel.tables.keys.first]!.rows;
        List<Member> importedMembers = [];
        for (var row in sheet.skip(1)) {
          // Skip the header row
          importedMembers.add(Member(
            id: ConverterUtils.parseStringToInt(_getCellValue(row[0])),
            // Use _getCellValue for safe value retrieval
            name: _getCellValue(row[1]),
            address: _getCellValue(row[2]),
            mobileNumber: _getCellValue(row[3]),
            recentlyPaid: double.tryParse(_getCellValue(row[4])) ?? 0.0,
            // Safe parsing to double
            currentBalance: double.tryParse(_getCellValue(row[5])) ?? 0.0,
            milkType: _getCellValue(row[6]),
            liters: double.tryParse(_getCellValue(row[7])) ?? 0.0,
            qr_code: jsonEncode({"m_id": ConverterUtils.parseStringToInt(_getCellValue(row[0]))})
          ));
        }
        Logger.info(importedMembers.toString());
        return importedMembers;
      }
    }
    return null;
  }

  String _getCellValue(Data? cell) {
    if (cell == null) return ''; // Return an empty string for null cells

    // Use _getCellValue for type-safe handling
    switch (cell.value.runtimeType) {
      case IntCellValue:
        return (cell.value as IntCellValue).value.toString();
      case DoubleCellValue:
        return (cell.value as DoubleCellValue).value.toString();
      case TextCellValue:
        return cell.value.toString();
      case FormulaCellValue:
        // Handle formulas, get the calculated value as a string
        return (cell.value as FormulaCellValue).toString();
      default:
        return ''; // Return an empty string for unknown types
    }
  }

  // Method to export members list to an Excel file
  Future<String> exportMembers(List<Member> members) async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();

      // Create or get a sheet
      var sheet = excel['Members'];

      // Style for headers
      CellStyle headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        textWrapping: TextWrapping.WrapText,
      );

      // Style for data cells
      CellStyle dataStyle = CellStyle(
        textWrapping: TextWrapping.WrapText,
      );

      // Add the header row with styling
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Name'),
        TextCellValue('Address'),
        TextCellValue('Mobile Number'),
        TextCellValue('Recently Paid'),
        TextCellValue('Current Balance'),
        TextCellValue('Milk Type'),
        TextCellValue('Liters')
      ]);

      // Apply header style
      for (var columnIndex = 0; columnIndex < 8; columnIndex++) {
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndex, rowIndex: 0))
            .cellStyle = headerStyle;
      }

      // Add member data rows
      for (int i = 0; i < members.length; i++) {
        var member = members[i];

        // Append each member's data row
        sheet.appendRow([
          IntCellValue(member.id),
          TextCellValue(member.name),
          TextCellValue(member.address),
          TextCellValue(member.mobileNumber),
          DoubleCellValue(member.recentlyPaid),
          DoubleCellValue(member.currentBalance),
          TextCellValue(member.milkType),
          DoubleCellValue(member.liters),
        ]);

        for (var columnIndex = 0; columnIndex < 8; columnIndex++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndex, rowIndex: i + 1))
              .cellStyle = dataStyle;
        }
      }

      excel.setDefaultSheet(sheet.sheetName);

      final String? path = await _saveExcelFile(excel);
      if (path != null) {
        Logger.info('Excel file exported successfully to $path');
        return path;
      } else {
        Logger.error('Error exporting Excel file.');
        return 'Error exporting Excel file.';
      }
    } catch (e) {
      Logger.error('Error during exportMembers: $e');
      return 'Error during exportMembers';
    }
  }

  Future<String?> _saveExcelFile(Excel excel) async {
    try {
      final Directory downloadsDirectory =
          Directory('/storage/emulated/0/Download');

      final String filePath = '${downloadsDirectory.path}/members_export.xlsx';

      // Write the file
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(join(filePath))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      Logger.error('Error saving Excel file: $e');
      return null;
    }
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }
}
