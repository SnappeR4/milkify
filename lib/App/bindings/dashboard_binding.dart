import 'package:get/get.dart';

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
  }
}
