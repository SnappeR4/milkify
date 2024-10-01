import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sale_controller.dart';

class SalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SaleController controller = Get.find();
    return Scaffold(
      // appBar: AppBar(title: Text('Sale')),
      body: Center(child: Text('Sale Page')),
    );
  }
}
