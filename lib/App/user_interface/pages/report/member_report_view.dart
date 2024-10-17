import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/member_report_controller.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';
import 'package:milkify/App/utils/date_picker_utils.dart';
import 'package:milkify/App/utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MemberReportPage extends StatelessWidget {
  final MemberReportController controller = Get.find<MemberReportController>();

  MemberReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Member Report'),
        ),
        body: Obx(
          () => controller.isPdfGenerated.value
              ? PdfPreview(
                  build: (format) => _generateCombinedPdf(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    if (controller.isMemberSelected.value) {
                      final selectedMember = controller.selectedMember;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      DateTime.parse(controller
                                              .toDate.value.isNotEmpty
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
                                      DateTime.parse(controller
                                              .fromDate.value.isNotEmpty
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
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller.fromDate.value.isNotEmpty &&
                                    controller.toDate.value.isNotEmpty) {
                                  controller
                                      .fetchTransactions(); // Fetch transactions based on selected date range
                                }
                              },
                              child: const Text('Fetch Transactions'),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${selectedMember['m_id']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Name: ${selectedMember['name']}'),
                                  Text(
                                      'Phone: ${selectedMember['mobile_number']}'),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  controller.setMemberSelected(
                                      false); // Deselect the member
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildMemberLedgerDetails(),
                          const Divider(),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller.saleTransactions.isNotEmpty ||
                                    controller.paymentTransactions.isNotEmpty) {
                                  controller.isPdfGenerated.value = true;
                                }
                              },
                              child: const Text('Member Ledger PDF'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 16.0),
                          Expanded(
                            child: controller.filteredMembers.isEmpty
                                ? MemberWidgets.buildEmptyListMessage()
                                : ListView.builder(
                                    itemCount:
                                        controller.filteredMembers.length,
                                    itemBuilder: (context, index) {
                                      final member =
                                          controller.filteredMembers[index];
                                      return MemberWidgets.buildMemberItem(
                                        context: context,
                                        member: member,
                                        onTap: () {
                                          controller.selectMember(
                                              member); // Set selected member
                                        },
                                        onDelete: () => Get.snackbar(
                                            'Member Delete',
                                            'No Deletion on this Page'),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }
                  }),
                ),
        ));
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search members',
        hintText: 'Search Members',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        controller.searchMembers(value);
      },
    );
  }

  Widget _buildMemberLedgerDetails() {
    final selectedMember = controller.selectedMember;
    return Column(
      children: [
        // FutureBuilder for Total Paid Amount
        FutureBuilder<double>(
          future: controller.getTotalPaidAmount(selectedMember['m_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching total paid amount');
            } else {
              return _buildLedgerRow(
                  'Total Paid Amount', snapshot.data?.toString() ?? '0.0');
            }
          },
        ),

        // FutureBuilder for Total Bill Amount
        FutureBuilder<double>(
          future: controller.getTotalBillAmount(selectedMember['m_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching total bill amount');
            } else {
              return _buildLedgerRow(
                  'Total Bill Amount', snapshot.data?.toString() ?? '0.0');
            }
          },
        ),
        _buildLedgerRow(
          'Current Balance',
          selectedMember['c_balance'].toString(),
        ),
      ],
    );
  }

  // Column(
  // children: [
  // // Opening Balance
  // // _buildLedgerRow(
  // //   'Opening Balance',
  // //   selectedMember['m_id'].toString(),
  // // ),
  // // Total Paid Amount
  // _buildLedgerRow(
  // 'Total Paid Amount',
  // controller.getTotalPaidAmount(selectedMember['m_id']).toString(),
  // ),
  // // Total Bill Amount
  // _buildLedgerRow(
  // 'Total Bill Amount',
  // controller.getTotalBillAmount(selectedMember['m_id']).toString(),
  // ),
  // // Current Balance
  // _buildLedgerRow(
  // 'Current Balance',
  // selectedMember['c_balance'].toString(),
  // ),
  // ],
  // );
  Widget _buildLedgerRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<Uint8List> _generateCombinedPdf() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final regularFont = await PdfGoogleFonts.nunitoExtraBold();

    // Define constants for chunk size
    const int saleRecordsPerPage = 17;
    const int paymentRecordsPerPage = 30;

    // Split sale transactions into chunks
    List<List<Transactions>> saleChunks = [];
    for (var i = 0;
        i < controller.saleTransactions.length;
        i += saleRecordsPerPage) {
      saleChunks.add(controller.saleTransactions.sublist(
        i,
        i + saleRecordsPerPage > controller.saleTransactions.length
            ? controller.saleTransactions.length
            : i + saleRecordsPerPage,
      ));
    }

    // Split payment transactions into chunks
    List<List<MemberPayment>> paymentChunks = [];
    for (var i = 0;
        i < controller.paymentTransactions.length;
        i += paymentRecordsPerPage) {
      paymentChunks.add(controller.paymentTransactions.sublist(
        i,
        i + paymentRecordsPerPage > controller.paymentTransactions.length
            ? controller.paymentTransactions.length
            : i + paymentRecordsPerPage,
      ));
    }

    // Calculate totals for sale
    final int totalSaleReceiptCount = controller.saleTransactions.length;
    final int totalSaleMembers =
        controller.saleTransactions.map((t) => t.memberId).toSet().length;
    final double totalSaleLiters =
        controller.saleTransactions.fold(0.0, (sum, t) => sum + t.liters);
    final double totalSaleAmount =
        controller.saleTransactions.fold(0.0, (sum, t) => sum + t.total);

    // Calculate totals for payment
    final int totalBillCount = controller.paymentTransactions.length;
    final int totalPaymentMembers =
        controller.paymentTransactions.map((t) => t.memberId).toSet().length;
    final double totalPaidAmount = controller.paymentTransactions
        .fold(0.0, (sum, t) => sum + t.paidAmount);

    // Add sale pages
    for (int i = 0; i < saleChunks.length; i++) {
      final chunk = saleChunks[i];
      pdf.addPage(
        pw.Page(
          build: (context) {
            final children = <pw.Widget>[
              pw.Align(
                alignment: pw.Alignment.center,
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
                  'Total'
                ],
                data: chunk.map((transaction) {
                  final status = transaction.billType == '2'
                      ? 'Edited'
                      : transaction.billType == '3'
                          ? 'Deleted'
                          : 'Regular';
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
                    fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(70),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(70),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(50),
                  7: const pw.FixedColumnWidth(50),
                  8: const pw.FixedColumnWidth(60),
                },
                border: pw.TableBorder.all(),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.center, // Center align the text
                child: pw.Text(
                  'Summary of Sale Report',
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
                  'Grand Total Amount'
                ],
                data: [
                  [
                    totalSaleReceiptCount.toString(),
                    totalSaleMembers.toString(),
                    totalSaleLiters.toStringAsFixed(2),
                    totalSaleAmount.toStringAsFixed(2)
                  ],
                ],
                headerStyle: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ];

            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: children);
          },
        ),
      );
    }

    // Add payment pages
    for (int i = 0; i < paymentChunks.length; i++) {
      final chunk = paymentChunks[i];
      pdf.addPage(
        pw.Page(
          build: (context) {
            final children = <pw.Widget>[
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Payment Report ${ConverterUtils.convertDateFormat(controller.fromDate.value.toString())} To ${ConverterUtils.convertDateFormat(controller.toDate.value.toString())}',
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
                  'Time',
                  'Bill No',
                  'Member ID',
                  'Paid Amount',
                  'Current Balance'
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
                    fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FixedColumnWidth(40),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(80),
                  5: const pw.FixedColumnWidth(80),
                },
                border: pw.TableBorder.all(),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
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
                  'Total Paid Amount'
                ],
                data: [
                  [
                    totalBillCount.toString(),
                    totalPaymentMembers.toString(),
                    totalPaidAmount.toStringAsFixed(2)
                  ],
                ],
                headerStyle: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ];

            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: children);
          },
        ),
      );
    }

    return pdf.save();
  }
}
