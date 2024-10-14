import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 1.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  String get appBarText {
    switch (selectedIndex.value) {
      case 0:
        return "SETTINGS".tr;
      case 1:
        return "SALE".tr;
      case 2:
        return "PAYMENT COLLECTION".tr;
      case 3:
        return "REPORTS".tr;
      default:
        return "Not Set";
    }
  }
}
