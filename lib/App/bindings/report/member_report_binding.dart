import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/member_report_controller.dart';

class MemberReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberReportController>(() => MemberReportController());
  }
}