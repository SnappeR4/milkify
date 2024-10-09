import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/payment_view_controller.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class PaymentView extends StatelessWidget {
  final PaymentViewController controller = Get.find<PaymentViewController>();

  PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Payment Transactions'),
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
                  if (controller.paymentTransactions.isEmpty) {
                    return Center(child: Text('No transactions found'));
                  }

                  return ListView.builder(
                    itemCount: controller.paymentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.paymentTransactions[index];
                      return ListTile(
                        title: Text('${transaction.billNo} - ${transaction.paidAmount}'),
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

    // Split transactions into chunks of 20 records per page
    const int recordsPerPage = 20;
    List<List<MemberPayment>> chunks = [];

    for (var i = 0; i < controller.paymentTransactions.length; i += recordsPerPage) {
      chunks.add(controller.paymentTransactions.sublist(
        i,
        i + recordsPerPage > controller.paymentTransactions.length
            ? controller.paymentTransactions.length
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
              pw.Text('Payment Report ${controller.fromDate.value} To ${controller.toDate.value}', style: pw.TextStyle(font: regularFont, fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Time', 'Bill No', 'Member ID', 'Paid Amount', 'Current Balance'],
                data: chunk.map((transaction) {
                  return [
                    transaction.date,
                    transaction.time.substring(0,8),
                    transaction.billNo,
                    transaction.memberId.toString(),
                    transaction.paidAmount.toString(),
                    transaction.currentBalance.toString(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: regularFont, fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: pw.FixedColumnWidth(60), // Adjust width for 'Date'
                  1: pw.FixedColumnWidth(40), // Adjust width for 'Time'
                  2: pw.FixedColumnWidth(60), // Adjust width for 'Bill No'
                  3: pw.FixedColumnWidth(60), // Adjust width for 'Member ID'
                  4: pw.FixedColumnWidth(80), // Adjust width for 'Paid Amount'
                  5: pw.FixedColumnWidth(80), // Adjust width for 'Current Balance'
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
