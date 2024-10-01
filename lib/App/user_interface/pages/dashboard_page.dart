import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../themes/app_theme.dart';
import 'settings_page.dart';
import 'sale_page.dart';
import 'report_page.dart';

class DashboardPage extends StatelessWidget {

  final DashboardController _controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milkify'),
        centerTitle: true,
      ),
      body: Obx(
            () {
          // Switch between pages based on the selected index
          switch (_controller.selectedIndex.value) {
            case 0:
              return SettingsPage();
            case 1:
              return SalePage(); // Initial page
            case 2:
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
              icon: Icon(Icons.assignment,color: AppTheme.color2),
              label: 'Sale',
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
