// lib/app/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../routes/app_routes.dart';

class RegisterController extends GetxController {
  // Dependencies
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Method to send OTP
  void sendOtp(BuildContext context) {
    if (formKey.currentState!.validate()) {
      AuthService.sentOtp(
        phone: phoneController.text,
        errorStep: () {
          Get.snackbar(
            "Error",
            "Error in sending OTP",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        nextStep: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("OTP Verification"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter 6-digit OTP"),
                  const SizedBox(height: 12),
                  Form(
                    key: GlobalKey<FormState>(),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: "Enter OTP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length != 6) {
                          return "Invalid OTP";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => handleSubmit(),
                  child: const Text("Submit"),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Handle after OTP is submitted
  void handleSubmit() {
    if (formKey.currentState!.validate()) {
      // Use the existing formKey
      AuthService.loginWithOtp(otp: otpController.text).then((value) async {
        if (value == "Success") {
          Get.offAllNamed(
              AppRoutes.dashboard); // Navigate to Dashboard using GetX
        } else {
          Get.back(); // Close the dialog
          Get.snackbar(
            "Error",
            value,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    }
  }
}
