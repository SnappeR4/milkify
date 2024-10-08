import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/user_interface/widgets/report_widget.dart';
import '../../controllers/report_controller.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sale Report
              const Center(child: Text('Sale Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              FutureBuilder<String>(
                future: controller.getCurrentDateSumLiters(),
                builder: (context, snapshotLiters) {
                  return FutureBuilder<String>(
                    future: controller.getCurrentDateSumTotal(),
                    builder: (context, snapshotTotal) {
                      if (snapshotLiters.connectionState == ConnectionState.waiting || snapshotTotal.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshotLiters.hasError || snapshotTotal.hasError) {
                        return const Text('Error fetching data');
                      }
                      return ReportTableWidget(
                        text1: 'Liters',
                        text2: 'Total',
                        value1: snapshotLiters.data ?? '0',
                        value2: snapshotTotal.data ?? '0',
                        onPressed: () {
                          Get.snackbar('Button Clicked', 'Sale Report Button was clicked!');
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20), // Add some spacing
              // Payment Report
              const Center(child: Text('Payment Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              FutureBuilder<String>(
                future: controller.getCurrentDateRecordCount(),
                builder: (context, snapshotCount) {
                  return FutureBuilder<String>(
                    future: controller.getCurrentDateSumPaidAmount(),
                    builder: (context, snapshotAmount) {
                      if (snapshotCount.connectionState == ConnectionState.waiting || snapshotAmount.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshotCount.hasError || snapshotAmount.hasError) {
                        return const Text('Error fetching data');
                      }
                      return ReportTableWidget(
                        text1: 'Receipts',
                        text2: 'Payments',
                        value1: snapshotCount.data ?? '0',
                        value2: snapshotAmount.data ?? '0',
                        onPressed: () {
                          Get.snackbar('Button Clicked', 'Payment Report Button was clicked!');
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20), // Add some spacing
              // Payment Report
              const Center(child: Text('Member Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              FutureBuilder<String>(
                future: controller.getTotalMemberCount(),
                builder: (context, snapshotMembers) {
                  return FutureBuilder<String>(
                    future: controller.getTotalLitersForMembers(),
                    builder: (context, snapshotLiters) {
                      if (snapshotMembers.connectionState == ConnectionState.waiting || snapshotLiters.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshotMembers.hasError || snapshotLiters.hasError) {
                        return const Text('Error fetching data');
                      }
                      return ReportTableWidget(
                        text1: 'Members',
                        text2: 'Liters',
                        value1: snapshotMembers.data ?? '0',
                        value2: snapshotLiters.data ?? '0',
                        onPressed: () {
                          Get.snackbar('Button Clicked', 'Member Report Button was clicked!');
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20), // Add some spacing
              // Payment Report
              const Center(child: Text('Edited Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              FutureBuilder<String>(
                future: controller.getEditedBillCount(),
                builder: (context, snapshotEdited) {
                  return FutureBuilder<String>(
                    future: controller.getDeletedBillCount(),
                    builder: (context, snapshotDeleted) {
                      if (snapshotEdited.connectionState == ConnectionState.waiting || snapshotDeleted.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshotEdited.hasError || snapshotDeleted.hasError) {
                        return const Text('Error fetching data');
                      }
                      return ReportTableWidget(
                        text1: 'Edited',
                        text2: 'Deleted',
                        value1: snapshotEdited.data ?? '0',
                        value2: snapshotDeleted.data ?? '0',
                        onPressed: () {
                          Get.snackbar('Button Clicked', 'Edited Report Button was clicked!');
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
