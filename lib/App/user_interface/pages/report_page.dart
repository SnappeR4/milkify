import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/routes/app_routes.dart';
import 'package:milkify/App/user_interface/widgets/report_widget.dart';
import '../../controllers/report_controller.dart';

class ReportPage extends StatelessWidget {
  final ReportController controller = Get.find<ReportController>();

  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.syncReportData();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('TODAY SALE REPORT',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                    text1: 'Liters',
                    text2: 'Total',
                    text3: 'CUSTOM SALE REPORT',
                    value1: controller.sumLiters.value,
                    value2: controller.sumTotal.value,
                    onPressed: () {
                      Get.toNamed(AppRoutes.transactionsView);
                    },
                  )),
              const SizedBox(height: 10),
              const Center(
                child: Text('TODAY PAYMENT REPORT',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                    text1: 'Receipts',
                    text2: 'Payments',
                    text3: 'CUSTOM PAYMENT REPORT',
                    value1: controller.recordCount.value,
                    value2: controller.sumPaidAmount.value,
                    onPressed: () {
                      Get.toNamed(AppRoutes.paymentView);
                    },
                  )),
              const SizedBox(height: 10),
              const Center(
                child: Text('MEMBER REPORT',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                    text1: 'Members',
                    text2: 'Liters',
                    text3: 'CUSTOM MEMBER REPORT',
                    value1: controller.totalMembers.value,
                    value2: controller.totalLiters.value,
                    onPressed: () {
                      Get.toNamed(AppRoutes.memberLedgerView);
                    },
                  )),
              const SizedBox(height: 10),
              const Center(
                child: Text('EDITED REPORT',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Obx(() => ReportTableWidget(
                    text1: 'Edited',
                    text2: 'Deleted',
                    text3: 'EDITED/DELETED REPORT',
                    value1: controller.editedCount.value,
                    value2: controller.deletedCount.value,
                    onPressed: () {
                      Get.toNamed(AppRoutes.editDeleteView);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
