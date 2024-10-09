import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/controllers/report/transactions_view_controller.dart'; // For formatting dates
import 'package:milkify/App/data/models/transaction.dart';
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
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              controller.isPdfGenerated.value = true;
            },
          ),
        ],
      ),
      body:Obx(
              () => controller.isPdfGenerated.value ? PdfPreview(
        build: (format) => _generatePdf(),
      ):Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    controller.setDateRange(pickedDate, DateTime.parse(controller.fromDate.value.isNotEmpty ? controller.fromDate.value : DateTime.now().toIso8601String()));
                  }
                },
                child: Obx((){return Text("From: ${controller.fromDate.value.isEmpty ? 'Select' : controller.fromDate.value}");}),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    controller.setDateRange(DateTime.parse(controller.toDate.value.isNotEmpty ? controller.toDate.value : DateTime.now().toIso8601String()), pickedDate);
                  }
                },
                child: Obx((){ return Text("To: ${controller.toDate.value.isEmpty ? 'Select' : controller.toDate.value}");}),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.fromDate.value.isNotEmpty && controller.toDate.value.isNotEmpty) {
                controller.fetchTransactions(); // Fetch transactions based on selected date range
              } else {
                // Show a message if dates are not selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select both dates')),
                );
              }
            },
            child: const Text('Fetch Transactions'),
          ),
          // Display transactions
          Expanded(
            child: Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(child: Text('No transactions found'));
              }

              return ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  return ListTile(
                    title: Text('${transaction.receiptNo} - ${transaction.total}'),
                    subtitle: Text('Date: ${transaction.date}'),
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

    // Split transactions into chunks of 22 records per page
    const int recordsPerPage = 20;
    List<List<Transactions>> chunks = [];

    for (var i = 0; i < controller.transactions.length; i += recordsPerPage) {
      chunks.add(controller.transactions.sublist(
        i,
        i + recordsPerPage > controller.transactions.length
            ? controller.transactions.length
            : i + recordsPerPage,
      ));
    }

    // Add a page for each chunk of 22 records
    for (final chunk in chunks) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sale Report ${controller.fromDate.value} To ${controller.toDate.value}', style: pw.TextStyle(font: regularFont, fontSize: 18)),
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
                  return [
                    transaction.date + transaction.time.substring(0,8),
                    transaction.receiptNo,
                    transaction.billType,
                    transaction.memberId.toString(),
                    transaction.memberOpeningBalance.toString(),
                    transaction.productId.toString(),
                    transaction.productRate.toString(),
                    transaction.liters.toString(),
                    transaction.total.toString(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: regularFont, fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: pw.FixedColumnWidth(70),  // Adjust width for 'Date'
                  1: pw.FixedColumnWidth(60),  // Adjust width for 'Receipt No'
                  2: pw.FixedColumnWidth(60),  // Adjust width for 'Bill Type'
                  3: pw.FixedColumnWidth(60),  // Adjust width for 'Member ID'
                  4: pw.FixedColumnWidth(70),  // Adjust width for 'Opening Balance'
                  5: pw.FixedColumnWidth(60),  // Adjust width for 'Product ID'
                  6: pw.FixedColumnWidth(50),  // Adjust width for 'Rate'
                  7: pw.FixedColumnWidth(50),  // Adjust width for 'Liters'
                  8: pw.FixedColumnWidth(60),  // Adjust width for 'Total'
                },
                border: pw.TableBorder.all(),
                cellPadding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              pw.SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
