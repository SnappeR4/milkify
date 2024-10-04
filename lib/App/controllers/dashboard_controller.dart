import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 1.obs;
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
  String get appBarText {
    switch(selectedIndex.value){
      case 0:
        return "SETTINGS";
      case 1:
        return "SALE";
      case 2:
        return "PAYMENT COLLECTION";
      case 3:
        return "REPORTS";
      default:
        return "Not Set";
    }
  }
}
