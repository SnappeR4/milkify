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
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitConfirmationDialog(context);
        return shouldExit; // Return true if the user wants to exit
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            return Text(_controller.appBarText);
          }),
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
                icon: Icon(Icons.settings, color: AppTheme.color2),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: Icon(Icons.shopping_cart, color: AppTheme.color2),
                label: 'Sale',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: Icon(Icons.assignment, color: AppTheme.color2),
                label: 'Collection',
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: Icon(Icons.pie_chart, color: AppTheme.color2),
                label: 'Report',
              ),
            ],
          ),
        ),
      ),
    );
  }

// Function to show the exit confirmation dialog
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                // Stay in the app
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                // Exit the app
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false; // Return false if dialog is dismissed by tapping outside
  }
}
