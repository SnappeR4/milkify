import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Observable for selected tab index
  var selectedIndex = 1.obs; // Default is CollectionPage (index 1)

  // Method to change the tab index
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
