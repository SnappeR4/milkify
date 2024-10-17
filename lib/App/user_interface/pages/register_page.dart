// // lib/app/pages/register_page.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/register_controller.dart';
//
// class RegisterPage extends StatelessWidget {
//   const RegisterPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Retrieve the RegisterController from GetX
//     // final RegisterController controller = Get.find<RegisterController>();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: SizedBox(
//           //add ? and loading here on otp submit
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Image.asset(
//                   "assets/images/register_page_image.jpg",
//                   fit: BoxFit.fill,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Welcome To ",
//                           style: TextStyle(
//                               fontSize: 32, fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           "Milkify👋",
//                           style: TextStyle(
//                               fontSize: 32, fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                     const Text("Enter your phone number to continue."),
//                     const SizedBox(height: 15),
//                     Form(
//                       key: controller.formKey,
//                       child: TextFormField(
//                         controller: controller.phoneController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           prefixText: "+91 ",
//                           labelText: "Enter your phone number",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(32),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.length != 10) {
//                             return "Invalid phone number";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     SizedBox(
//                       height: 50,
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => controller.sendOtp(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF65C504),
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text("Send OTP"),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
