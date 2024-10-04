import 'package:get/get.dart';
import 'package:milkify/App/controllers/collection_controller.dart';
import 'package:milkify/App/controllers/settings/member_settings_controller.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/report_controller.dart';
import '../controllers/sale_controller.dart';
import '../controllers/settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ReportController>(() => ReportController());
    Get.lazyPut<SaleController>(() => SaleController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<CollectionController>(() => CollectionController());
    Get.lazyPut<MemberController>(() => MemberController());
  }
}
