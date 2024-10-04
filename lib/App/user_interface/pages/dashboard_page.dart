import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/user_interface/pages/collection_page.dart';
import '../../controllers/dashboard_controller.dart';
import '../themes/app_theme.dart';
import 'settings_page.dart';
import 'sale_page.dart';
import 'report_page.dart';

class DashboardPage extends StatelessWidget {

  final DashboardController _controller = Get.find<DashboardController>();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx((){ return Text(_controller.appBarText);}),
        centerTitle: true,
      ),
      body: Obx(
            () {
          // Switch between pages based on the selected index
          switch (_controller.selectedIndex.value) {
            case 0:
              return const SettingsPage();
            case 1:
              return SalePage(); // Initial page
            case 2:
              return CollectionPage();
            case 3:
              return ReportPage();
            default:
              return SalePage(); // Default page
          }
        },
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              backgroundColor: AppTheme.color1,
          currentIndex: _controller.selectedIndex.value,
          onTap: (index) {
            _controller.changeTabIndex(index);
          },
              selectedItemColor: AppTheme.color2,
          items: const [
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.settings,color: AppTheme.color2),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.shopping_cart,color: AppTheme.color2),
              label: 'Sale',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.assignment,color: AppTheme.color2),
              label: 'Collection',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.pie_chart,color: AppTheme.color2),
              label: 'Report',
            ),
          ],
        ),
      ),
    );
  }
}
