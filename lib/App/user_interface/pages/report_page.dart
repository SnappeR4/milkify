import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/user_interface/widgets/report_widget.dart';
import '../../controllers/report_controller.dart';

class ReportPage extends StatelessWidget {
  ReportPage({super.key});

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
              const Center(
                child: Text('TODAY SALE REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                text1: 'Liters',
                text2: 'Total',
                value1: controller.sumLiters.value,
                value2: controller.sumTotal.value,
                onPressed: () {
                  Get.snackbar('Button Clicked', 'Sale Report Button was clicked!');
                },
              )),

              const SizedBox(height: 20),
              const Center(
                child: Text('TODAY PAYMENT REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                text1: 'Receipts',
                text2: 'Payments',
                value1: controller.recordCount.value,
                value2: controller.sumPaidAmount.value,
                onPressed: () {
                  Get.snackbar('Button Clicked', 'Payment Report Button was clicked!');
                },
              )),

              const SizedBox(height: 20),
              const Center(
                child: Text('MEMBER REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                text1: 'Members',
                text2: 'Liters',
                value1: controller.totalMembers.value,
                value2: controller.totalLiters.value,
                onPressed: () {
                  Get.snackbar('Button Clicked', 'Member Report Button was clicked!');
                },
              )),

              const SizedBox(height: 20),
              const Center(
                child: Text('EDITED REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                text1: 'Edited',
                text2: 'Deleted',
                value1: controller.editedCount.value,
                value2: controller.deletedCount.value,
                onPressed: () {
                  Get.snackbar('Button Clicked', 'Edited Report Button was clicked!');
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
