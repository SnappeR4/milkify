import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/controllers/collection_controller.dart';
import 'package:milkify/App/controllers/sale_controller.dart';

// import 'package:milkify/App/controllers/sms_controller.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/data/services/member_service.dart';
import 'package:milkify/App/user_interface/themes/app_theme.dart';
import 'package:milkify/App/user_interface/widgets/loading_dialog.dart';
import 'package:milkify/App/user_interface/widgets/qr_scanner.dart';
import 'package:milkify/App/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/services/database_helper.dart';
import '../../utils/logger.dart';
import 'dart:ui' as ui;
class MemberController extends GetxController {
  final MembersService membersService = MembersService();

  // final SmsController smsController = Get.put(SmsController());
  RxMap<String, Object?> settings = <String, Object?>{}.obs;

  // List to store the members
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;

  // List to store filtered members for the search
  final RxList<Map<String, dynamic>> filteredMembers =
      <Map<String, dynamic>>[].obs;

  // To hold the search query
  final RxString searchQuery = ''.obs;
  var qrCodeResult = ''.obs;

  // Member ID
  final RxString newMemberId = ''.obs;

  // Database instance
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Database database;

  // Method to add a member
  Future<void> addMember(Map<String, dynamic> newMember) async {
    Logger.info(newMember.toString());
    await database.insert('members', newMember);
    fetchMembers();
  }

  //for sale page
  var isMemberSelected = false.obs;

  //for payment page
  var isMemberSelectedPayment = false.obs;
  final RxMap<String, dynamic> selectedMember = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> selectedMemberPayment = <String, dynamic>{}.obs;
  final SaleController saleController = Get.find<SaleController>();
  final CollectionController collectionController =
      Get.find<CollectionController>();

  void selectMember(Map<String, dynamic> member) async {
    selectedMember.assignAll(member);
    isMemberSelected.value = true;
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Map<String, dynamic>> result = await database.query(
      'transactions',
      where: 'm_id = ? AND date = ?',
      whereArgs: [
        member['m_id'],
        currentDate
      ], // Arguments to replace the placeholders
    );
    // Get current date in the required format

    // Check if transaction exists for the member (assuming you have a fetchTransactionByDateAndMember method)
    bool isTransactionExist = result.isNotEmpty;

    if (isTransactionExist && settings['continue_coll'] == 0) {
      Get.defaultDialog(
        title: "Transaction Exists",
        middleText:
            "A transaction for this member has already been made today. Do you want to continue?",
        backgroundColor: AppTheme.color1,
        // Set background color to white
        textCancel: "Cancel",
        textConfirm: "Continue",
        onCancel: () {
          isMemberSelected.value = false; // Deselect member if canceled
        },
        onConfirm: () {
          saleController.fetchTransactions(); // Continue if confirmed
          Get.back(); // Close dialog
        },
        cancelTextColor: AppTheme.color7,
        confirmTextColor: AppTheme.color1,
        // Optional: set text color for confirm button
        buttonColor: AppTheme.color2,
        // Set button color based on theme
        barrierDismissible: false, // Make it mandatory to choose an option
      );
    } else {
      saleController.fetchTransactions();
    }
  }

  Future<void> setMemberSelected(bool selected) async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    members.assignAll(memberList);
    filteredMembers.assignAll(memberList);
    isMemberSelected.value = selected;
  }

  //for payment page
  void selectMemberPayment(Map<String, dynamic> member) {
    selectedMemberPayment.assignAll(member);
    isMemberSelectedPayment.value = true;
    collectionController.fetchPayments(member['m_id']);
  }

  Future<void> setMemberSelectedPayment(bool selected) async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    members.assignAll(memberList);
    filteredMembers.assignAll(memberList);
    isMemberSelectedPayment.value = selected;
  }

  // Method to edit a member
  Future<void> editMember(Map<String, dynamic> member) async {
    await database.update(
      'members',
      member,
      where: 'm_id = ?',
      whereArgs: [member['m_id']],
    );
    Get.snackbar("Member", "Member Update Success");
    fetchMembers(); // Refresh the member list
  }

  // Fetch members from the database
  Future<void> fetchMembers() async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    members.assignAll(memberList);
    searchMembers(searchQuery.value); // Apply the search if any
  }

  Future<void> syncMembers() async {
    final List<Map<String, dynamic>> memberList =
        await database.query('members');
    members.assignAll(memberList);
    filteredMembers.assignAll(memberList);
  }

  void searchMembers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // If search query is empty, reset the filtered members list
      filteredMembers.assignAll(members);
    } else {
      filteredMembers.assignAll(
        members.where((member) {
          final name = member['name'].toLowerCase();
          final id = member['m_id']
              .toString(); // Assuming 'm_id' is an integer or string
          final mobileNumber = member['mobile_number'].toString();

          // Check if the query matches either name, id, or mobile number
          return name.contains(query.toLowerCase()) ||
              id.contains(query) ||
              mobileNumber.contains(query);
        }).toList(),
      );
    }
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    filteredMembers.assignAll(members);
  }

  // Delete a member from the database
  Future<void> deleteMember(int memberId) async {
    await database.delete(
      'members',
      where: 'm_id = ?',
      whereArgs: [memberId],
    );
    fetchMembers(); // Refresh the list after deletion
  }

  // Generate a new member ID
  Future<void> generateNewMemberId() async {
    final List<Map<String, dynamic>> result = await database.query(
      'members',
      columns: ['m_id'],
      orderBy: 'm_id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      int lastId = result.first['m_id'] as int;
      newMemberId.value = (lastId + 1).toString();
    } else {
      newMemberId.value = '1'; // Start from 1 if no members exist
    }
  }

  Future<void> submitTransaction(Map<String, dynamic> member, double liters,
      double rate, double total) async {
    // var newTransaction = {
    //   'm_id': member['m_id'],
    //   'name': member['name'],
    //   'liters': liters,
    //   'rate': rate,
    //   'total': total,
    // };
    Map<String, dynamic>? lastTransaction =
        await DatabaseHelper.getLastTransaction();
    int trId = 1;
    // Initialize receipt number
    String newReceiptNo = '001';

    if (lastTransaction != null) {
      trId = lastTransaction['tr_id'] + 1;

      String lastReceiptNo = lastTransaction['receipt_no'];
      int receiptNumber = int.parse(lastReceiptNo) + 1;

      newReceiptNo = receiptNumber.toString().padLeft(3, '0');
    }

    int pId = 0;
    switch (member['milk_type']) {
      case 'Cow':
        pId = 1;
        break;
      case 'Buffalo':
        pId = 2;
        break;
      case 'Mix':
        pId = 3;
        break;
      default:
        pId = 0;
        break;
    }
    Transactions transaction = Transactions(
      id: trId,
      // Assuming auto-increment ID
      receiptNo: newReceiptNo,
      // Example receipt number
      billType: '1',
      //1 normal 2 edited,3 void, 4 return
      memberId: member['m_id'],
      productId: pId,
      productRate: rate,
      liters: liters,
      addOn: 0.0,
      total: total,
      date: DateTime.now().toIso8601String().split('T')[0],
      // Current date
      time: DateTime.now().toIso8601String().split('T')[1],
      // Current time
      timestamp: DateTime.now().toString(),
      editedTimestamp: '',
      paymentMode: '0',
      paymentReceivedFlag: 0,
      memberOpeningBalance: member['c_balance'],
      voidBillFlag: 0,
    );

    await DatabaseHelper.saveTransaction(transaction);
    Logger.info(transaction.toMap().toString());

    if (settings['sms_enable'] == 1) {
      // String totalBalance = (member['c_balance'] + total).toString();
      // String message =
      //     '''Receipt No: $newReceiptNo\nMilk Type : ${member['milk_type']}\nLiters    : $liters\nRate      : $rate\nTotal     : $total\nC.Balance : $totalBalance''';
      if (member["mobile_number"].toString().length == 10) {
        // String phoneNumber = "+91$member['mobile_number']";
        // smsController.sendSms(
        //   phoneNumber,
        //   message,
        // );
        // Get.snackbar("Payment", smsController.sendingStatus as String);
      }
    } else {
      Get.snackbar('Success', 'Transaction Saved successfully');
    }
  }

  Future<void> loadSettings() async {
    settings.value =
        await DatabaseHelper.getSettings();
  }

  Future<void> importMembers() async {
    List<Member>? importedMembers = await membersService.importMembers();
    if (importedMembers != null) {
      await deleteAllMembers();

      // Insert imported members into the database
      for (var member in importedMembers) {
        if (member.id > 0) {
          await insertMemberIntoDatabase(member);
        }
      }
      await fetchMembers();
      Get.snackbar("Member File", "Imported Successfully");
    }
  }

  // Method to delete all members from the database
  Future<void> deleteAllMembers() async {
    await database.delete('members');
  }

  // Method to insert a member into the database
  Future<void> insertMemberIntoDatabase(Member member) async {
    Map<String, dynamic> memberData = {
      'm_id': member.id,
      'name': member.name,
      'address': member.address,
      'mobile_number': member.mobileNumber,
      'recently_paid': member.recentlyPaid,
      'c_balance': member.currentBalance,
      'milk_type': member.milkType,
      'liters': member.liters,
      'qr_code': jsonEncode({"m_id": member.id}),
    };

    // Insert the member into the database
    await database.insert(
      'members', // Name of the table
      memberData,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if already exists
    );
  }

  Future<void> exportMembers() async {
    try {
      List<Member> membersList = members
          .map((member) => Member(
                id: member['m_id'],
                name: member['name'],
                address: member['address'],
                mobileNumber: member['mobile_number'],
                recentlyPaid: member['recently_paid'],
                currentBalance: member['c_balance'],
                milkType: member['milk_type'],
                liters: member['liters'],
                qr_code: '',
              ))
          .toList();

      String response = await membersService.exportMembers(membersList);
      await LoadingDialog.dismiss();
      Get.snackbar("Member File", response);
    } catch (e) {
      Logger.error('Error exporting members: $e');
    }
  }

  Future<void> scanQrCode(bool sale, bool toggle) async {
    // Use QR code scanner here
    final result = await Get.to(() => QrScannerScreen(sale: sale,toggle: toggle,));

    if (result != null) {
      Logger.info(result.toString());

      // Extract the QR code and toggle value from the result
      final String? code = result['code']; // Ensure this is extracted as a String
      final bool toggle = result['toggle'] ?? false;

      if (code != null) {
        try {
          final decodedJson = jsonDecode(code);

          final String memberId = decodedJson['m_id'].toString();
          Logger.info('Decoded Member ID: $memberId');
          qrCodeResult.value = code;
          final member = searchMembersQR(ConverterUtils.parseStringToInt(memberId));
          if (toggle) {
            double rate = await getRateForMilkType(member['milk_type']);
            double liters = double.parse(member['liters'].toString());
            Logger.info("$rate + $liters");
            if (rate > 0.0 && liters > 0.0) {
              await submitTransaction(member, liters, rate, liters * rate);
              await Future.delayed(const Duration(seconds: 1));
              await scanQrCode(sale,toggle);
            } else {
              Get.snackbar("Error", "Liters or rate cannot be 0");
            }
          }else {
            if (sale) {
              selectMember(member);
            } else {
              selectMemberPayment(member);
            }
          }
        } catch (e) {
          Logger.error('Failed to decode JSON from QR code: $e');
          Get.snackbar('Error', 'Invalid QR code data.');
        }
      }
    }
  }

  Future<double> getRateForMilkType(String milkType) async {
    final List<Map<String, dynamic>> products = await database.query('product');
    for (var product in products) {
      switch (product['name']) {
        case 'Cow':
          return double.tryParse(product['rate'].toString()) ?? 0.0;
        case 'Buffalo':
          return double.tryParse(product['rate'].toString()) ?? 0.0 ;
        case 'Mix':
          return double.tryParse(product['rate'].toString()) ?? 0.0;
        default:
          return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> searchMembersQR(int query) {
    final member = filteredMembers.firstWhere(
      (member) => member['m_id'] == query,
    );
    return member;
  }

// Method to export all QR codes to /Download/Milkify QR
  Future<void> exportAllQrCodes() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      await LoadingDialog.dismiss();
      Get.snackbar('Permission Denied', 'Storage permission is required to save QR codes');
      return;
    }

    // Create folder in Download directory
    final downloadDir = Directory('/storage/emulated/0/Download/Milkify QR');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    try {
      // Loop through all members and generate/save QR codes
      for (var member in filteredMembers) {
        await generateAndSaveQrCode(member, downloadDir.path);
      }
      await LoadingDialog.dismiss();
      Get.snackbar('Success', 'All QR codes exported to Download/Milkify QR folder ');
    } catch (e) {
      await LoadingDialog.dismiss();
      Get.snackbar('Error', 'An error occurred while exporting QR codes: $e');
    }
  }
  Future<void> generateAndSaveQrCode(Map<String, dynamic> member, String path) async {
    try {
      // Set padding
      const double padding = 20.0;

      // Define QR code size and other sizes
      const double qrSize = 300.0;
      const double textHeight = 50.0;
      const double totalWidth = qrSize + 2 * padding;  // Total width with padding
      const double totalHeight = qrSize + textHeight + 3 * padding; // Total height with padding for QR, text, and additional spacing

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      // Draw background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, totalWidth, totalHeight),
        paint,
      );

      final qrImage = QrPainter(
        data: jsonEncode({"m_id": member['m_id'].toString()}),
        version: QrVersions.auto,
        gapless: false,
        errorCorrectionLevel: QrErrorCorrectLevel.H,  // Higher error correction
      );

      // Paint the QR code with padding
      // Translate the canvas to account for padding
      canvas.translate(padding, padding);
      qrImage.paint(canvas, const Size(qrSize, qrSize));

      // Prepare the text below the QR code
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'ID: ${member['m_id']}\nName: ${member['name']}',
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );

      // Layout the text
      textPainter.layout(
        minWidth: 0,
        maxWidth: qrSize, // Keep text width the same as QR code width
      );

      // Paint the text
      textPainter.paint(canvas, Offset(
        (qrSize - textPainter.width) / 2, // Center the text below the QR code
        padding + qrSize + padding, // Place it below the QR code with padding
      ));

      // Convert the canvas to an image and save it with high resolution
      final img = await pictureRecorder.endRecording().toImage(
        // (totalWidth * 3).toInt(),
        // (totalHeight * 3).toInt(),
        (totalWidth).toInt(),
        (totalHeight).toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the image
      final file = File('$path/qr_code_${member['m_id']}.png');
      await file.writeAsBytes(pngBytes);
    } catch (e) {
      throw Exception('Failed to generate QR code for member ${member['m_id']}: $e');
    }
  }
  // Future<void> generateAndSaveQrCode(Map<String, dynamic> member, String path) async {
  //   try {
  //     // Set padding
  //     const double padding = 20.0;
  //
  //     // Define sizes
  //     const double qrSize = 200.0;
  //     const double textHeight = 50.0;
  //     const double totalWidth = qrSize + 2 * padding;  // Total width with padding
  //     const double totalHeight = qrSize + textHeight + 3 * padding; // Total height with padding for QR, text, and additional spacing
  //
  //     final pictureRecorder = ui.PictureRecorder();
  //     final canvas = Canvas(pictureRecorder);
  //
  //     // Draw background
  //     final paint = Paint()..color = Colors.white;
  //     canvas.drawRect(
  //       const Rect.fromLTWH(0, 0, totalWidth, totalHeight),
  //       paint,
  //     );
  //
  //     // Create QR code
  //     final qrImage = QrPainter(
  //       data: member['m_id'].toString(),
  //       version: QrVersions.auto,
  //       gapless: false,
  //       // color: Colors.black,
  //       // emptyColor: Colors.white,
  //     );
  //
  //     // Paint the QR code with padding
  //     // Translate the canvas to account for padding
  //     canvas.translate(padding, padding);
  //     qrImage.paint(canvas, const Size(qrSize, qrSize));
  //
  //     // Prepare the text below the QR code
  //     final textPainter = TextPainter(
  //       text: TextSpan(
  //         text: 'ID: ${member['m_id']}\nName: ${member['name']}',
  //         style: const TextStyle(color: Colors.black, fontSize: 16.0),
  //       ),
  //       textAlign: TextAlign.center,
  //       textDirection: ui.TextDirection.ltr,
  //     );
  //
  //     // Layout the text
  //     textPainter.layout(
  //       minWidth: 0,
  //       maxWidth: qrSize, // Keep text width the same as QR code width
  //     );
  //
  //     // Paint the text
  //     textPainter.paint(canvas, Offset(
  //       (qrSize - textPainter.width) / 2, // Center the text below the QR code
  //       padding + qrSize + padding, // Place it below the QR code with padding
  //     ));
  //
  //     // Convert the canvas to an image and save it
  //     final img = await pictureRecorder.endRecording().toImage(
  //       totalWidth.toInt(),
  //       totalHeight.toInt(),
  //     );
  //     final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  //     final pngBytes = byteData!.buffer.asUint8List();
  //
  //     // Save the image
  //     final file = File('$path/qr_code_${member['m_id']}.png');
  //     await file.writeAsBytes(pngBytes);
  //   } catch (e) {
  //     throw Exception('Failed to generate QR code for member ${member['m_id']}: $e');
  //   }
  // }



  @override
  Future<void> onInit() async {
    super.onInit();
    database = await _dbHelper.database;
    fetchMembers();
    loadSettings();
  }
}
