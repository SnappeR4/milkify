import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/payment_view_controller.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/utils/date_picker_utils.dart';
import 'package:milkify/App/utils/utils.dart';
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
                if (controller.paymentTransactions.isNotEmpty) {
                  controller.isPdfGenerated.value = true;
                }
              },
            ),
          ],
        ),
        body: Obx(
          () => controller.isPdfGenerated.value
              ? PdfPreview(
                  build: (format) => _generatePdf(),
                )
              : Column(
                  children: [
                    // Date range selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate =
                                await DatePickerUtils.pickDate(
                                    context, DateTime.now());
                            if (pickedDate != null) {
                              controller.setDateRange(
                                pickedDate,
                                DateTime.parse(
                                    controller.toDate.value.isNotEmpty
                                        ? controller.toDate.value
                                        : DateTime.now().toIso8601String()),
                              );
                            }
                          },
                          child: Text(
                              "From: ${controller.fromDate.value.isEmpty ? 'Select' : controller.fromDate.value}"),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate =
                                await DatePickerUtils.pickDate(
                                    context, DateTime.now());
                            if (pickedDate != null) {
                              controller.setDateRange(
                                DateTime.parse(
                                    controller.fromDate.value.isNotEmpty
                                        ? controller.fromDate.value
                                        : DateTime.now().toIso8601String()),
                                pickedDate,
                              );
                            }
                          },
                          child: Text(
                              "To: ${controller.toDate.value.isEmpty ? 'Select' : controller.toDate.value}"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.fromDate.value.isNotEmpty &&
                            controller.toDate.value.isNotEmpty) {
                          controller
                              .fetchTransactions(); // Fetch transactions based on selected date range
                        }
                      },
                      child: const Text('Fetch Transactions'),
                    ),
                    // Display transactions
                    Expanded(
                      child: Obx(() {
                        if (controller.paymentTransactions.isEmpty) {
                          return const Center(
                              child: Text('No transactions found'));
                        }

                        return ListView.builder(
                          itemCount: controller.paymentTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                controller.paymentTransactions[index];
                            return ListTile(
                              title: Text('Bill No: ${transaction.billNo}'),
                              subtitle: Text(
                                  'M ID: ${transaction.memberId} | Remaining: ₹${transaction.currentBalance}'),
                              trailing: Text('₹${transaction.paidAmount}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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

    // Split transactions into chunks of 30 records per page
    const int recordsPerPage = 30;
    List<List<MemberPayment>> chunks = [];

    for (var i = 0;
        i < controller.paymentTransactions.length;
        i += recordsPerPage) {
      chunks.add(controller.paymentTransactions.sublist(
        i,
        i + recordsPerPage > controller.paymentTransactions.length
            ? controller.paymentTransactions.length
            : i + recordsPerPage,
      ));
    }

    // Calculate totals
    final int totalBillCount = controller.paymentTransactions.length;
    final int totalMembers =
        controller.paymentTransactions.map((t) => t.memberId).toSet().length;
    final double totalPaid = controller.paymentTransactions
        .fold(0.0, (sum, t) => sum + t.paidAmount);

    // Add a page for each chunk of records
    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      pdf.addPage(
        pw.Page(
          build: (context) {
            final children = <pw.Widget>[
              pw.Align(
                alignment: pw.Alignment.center, // Center align the text
                child: pw.Text(
                  'Payment Report ${ConverterUtils.convertDateFormat(controller.fromDate.value.toString())} To ${ConverterUtils.convertDateFormat(controller.toDate.value.toString())}',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Time',
                  'Bill No',
                  'Member ID',
                  'Paid Amount',
                  'Current Balance',
                ],
                data: chunk.map((transaction) {
                  return [
                    transaction.date,
                    transaction.time.substring(0, 8),
                    transaction.billNo,
                    transaction.memberId.toString(),
                    transaction.paidAmount.toString(),
                    transaction.currentBalance.toString(),
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
                  0: const pw.FixedColumnWidth(60),
                  // Adjust width for 'Date'
                  1: const pw.FixedColumnWidth(40),
                  // Adjust width for 'Time'
                  2: const pw.FixedColumnWidth(60),
                  // Adjust width for 'Bill No'
                  3: const pw.FixedColumnWidth(60),
                  // Adjust width for 'Member ID'
                  4: const pw.FixedColumnWidth(80),
                  // Adjust width for 'Paid Amount'
                  5: const pw.FixedColumnWidth(80),
                  // Adjust width for 'Current Balance'
                },
                border: pw.TableBorder.all(),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ];

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
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  headers: [
                    'Total Bill Count',
                    'Total Members',
                    'Total Paid Amount',
                  ],
                  data: [
                    [
                      totalBillCount.toString(),
                      totalMembers.toString(),
                      totalPaid.toStringAsFixed(2),
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
                  cellPadding:
                      const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
