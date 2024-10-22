import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    Get.dialog(
      Center(
        child: Lottie.asset(
          'assets/lotties/loading_animation.json',
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
      barrierDismissible: false,
    );
  }
  static Future<void> dismiss() async {
    if (Get.isDialogOpen ?? false) {
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    }
  }
}
