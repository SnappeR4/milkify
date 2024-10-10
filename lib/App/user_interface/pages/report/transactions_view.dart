import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/transactions_view_controller.dart'; // For formatting dates
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/utils/date_picker_utils.dart';
import 'package:milkify/App/utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class TransactionView extends StatelessWidget {
  final TransactionViewModel controller = Get.find<TransactionViewModel>();

  TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sale Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              if(controller.transactions.isNotEmpty) {
                controller.isPdfGenerated.value = true;
              }
            },
          ),
        ],
      ),
      body:Obx(
              () => controller.isPdfGenerated.value ? PdfPreview(
        build: (format) => _generatePdf(),
      ):Column(
        children: [
          // Date range selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await DatePickerUtils.pickDate(context, DateTime.now());
                  if (pickedDate != null) {
                    controller.setDateRange(
                      pickedDate,
                      DateTime.parse(controller.toDate.value.isNotEmpty
                          ? controller.toDate.value
                          : DateTime.now().toIso8601String()),
                    );
                  }
                },
                child: Text("From: ${controller.fromDate.value.isEmpty ? 'Select' : controller.fromDate.value}"),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await DatePickerUtils.pickDate(context, DateTime.now());
                  if (pickedDate != null) {
                    controller.setDateRange(
                      DateTime.parse(controller.fromDate.value.isNotEmpty
                          ? controller.fromDate.value
                          : DateTime.now().toIso8601String()),
                      pickedDate,
                    );
                  }
                },
                child: Text("To: ${controller.toDate.value.isEmpty ? 'Select' : controller.toDate.value}"),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.fromDate.value.isNotEmpty && controller.toDate.value.isNotEmpty) {
                controller.fetchTransactions(); // Fetch transactions based on selected date range
              }
            },
            child: const Text('Fetch Transactions'),
          ),
          // Display transactions
          Expanded(
            child: Obx(() {
              if (controller.transactions.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }

              return ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  final String status;
                  if (transaction.billType == '2') {
                    status = ' Edited';
                  } else {
                    status = transaction.billType == '3'
                      ? ' Deleted'
                      : ' ';
                  }
                  return ListTile(
                    title: Text('Receipt No: ${transaction.receiptNo} $status'),
                    subtitle: Text('M ID: ${transaction.memberId} | Liters: ${transaction.liters} | Rate: ₹${transaction.productRate}'),
                    trailing: Text('₹${transaction.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ));
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final regularFont = await PdfGoogleFonts.nunitoExtraBold();

    // Split transactions into chunks of 20 records per page
    const int recordsPerPage = 17;
    List<List<Transactions>> chunks = [];

    for (var i = 0; i < controller.transactions.length; i += recordsPerPage) {
      chunks.add(controller.transactions.sublist(
        i,
        i + recordsPerPage > controller.transactions.length
            ? controller.transactions.length
            : i + recordsPerPage,
      ));
    }

    // Calculate totals
    final int totalReceiptCount = controller.transactions.length;
    final int totalMembers = controller.transactions.map((t) => t.memberId).toSet().length;
    final double totalLiters = controller.transactions.fold(0.0, (sum, t) => sum + t.liters);
    final double totalAmount = controller.transactions.fold(0.0, (sum, t) => sum + t.total);

    // Add a page for each chunk of 20 records
    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];

      pdf.addPage(
        pw.Page(
          build: (context) {
            final children = <pw.Widget>[
              pw.Align(
                alignment: pw.Alignment.center, // Center align the text
                child: pw.Text(
                  'Sale Report ${ConverterUtils.convertDateFormat(controller.fromDate.value.toString())} To ${ConverterUtils.convertDateFormat(controller.toDate.value.toString())}',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Receipt No',
                  'Bill Type',
                  'Member ID',
                  'Opening Balance',
                  'Product ID',
                  'Rate',
                  'Liters',
                  'Total',
                ],
                data: chunk.map((transaction) {
                  final status = transaction.billType == '2'
                      ? ' Edited'
                      : transaction.billType == '3'
                      ? ' Deleted'
                      : ' Regular';
                  return [
                    transaction.date + transaction.time.substring(0, 8),
                    transaction.receiptNo,
                    status,
                    transaction.memberId.toString(),
                    transaction.memberOpeningBalance.toString(),
                    transaction.productId.toString(),
                    transaction.productRate.toString(),
                    transaction.liters.toString(),
                    transaction.total.toString(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(70), // Adjust width for 'Date'
                  1: const pw.FixedColumnWidth(60), // Adjust width for 'Receipt No'
                  2: const pw.FixedColumnWidth(60), // Adjust width for 'Bill Type'
                  3: const pw.FixedColumnWidth(60), // Adjust width for 'Member ID'
                  4: const pw.FixedColumnWidth(70), // Adjust width for 'Opening Balance'
                  5: const pw.FixedColumnWidth(60), // Adjust width for 'Product ID'
                  6: const pw.FixedColumnWidth(50), // Adjust width for 'Rate'
                  7: const pw.FixedColumnWidth(50), // Adjust width for 'Liters'
                  8: const pw.FixedColumnWidth(60), // Adjust width for 'Total'
                },
                border: pw.TableBorder.all(),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              pw.SizedBox(height: 10),
            ];

            // If this is the last chunk and there's space for the summary
            if (i == chunks.length - 1) {
              children.addAll([
                pw.Align(
                  alignment: pw.Alignment.center, // Center align the text
                  child: pw.Text(
                    'Summary of Payment Report',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Total Receipt Count',
                    'Total Members',
                    'Total Liters',
                    'Grand Total Amount',
                  ],
                  data: [
                    [
                      totalReceiptCount.toString(),
                      totalMembers.toString(),
                      totalLiters.toStringAsFixed(2),
                      totalAmount.toStringAsFixed(2),
                    ],
                  ],
                  headerStyle: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                  cellAlignment: pw.Alignment.centerLeft,
                  border: pw.TableBorder.all(),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
              ]);
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            );
          },
        ),
      );
    }

    return pdf.save();
  }

}
