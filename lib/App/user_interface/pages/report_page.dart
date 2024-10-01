import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/report_controller.dart';
class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find();
    return Scaffold(
      // appBar: AppBar(title: Text('Reports')),
      body: Center(child: Text('Report Page')),
    );
  }
}
