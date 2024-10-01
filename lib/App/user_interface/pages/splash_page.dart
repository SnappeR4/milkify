// lib/app/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/splash_controller.dart';
import '../widgets/lottie_animation.dart';
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the controller
    final SplashController controller = Get.find();

    return Scaffold(
      body: Center(
        child: Obx(() {
          // Use the controller to check if something is loading
          return controller.isLoading.value
              ? const CircularProgressIndicator()
              : LottieAnimation(
            assetPath: 'assets/lotties/splash_animation.json',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
          );
        }),
      ),
    );
  }
}

