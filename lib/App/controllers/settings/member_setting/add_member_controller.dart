// lib/app/controllers/add_member_controller.dart
import 'package:get/get.dart';

import '../../../utils/logger.dart';
import '../member_settings_controller.dart';

class AddMemberController extends GetxController {
  final MemberController memberSettingsController = Get.find<MemberController>();
  @override
  Future<void> onInit() async {
    super.onInit();
    await memberSettingsController.generateNewMemberId();
  }

  // Add a new member
  Future<void> addMember(Map<String, dynamic> memberData) async {
    try {
      await memberSettingsController.addMember(memberData); // Call the method from MemberSettingsController
      Get.snackbar('Success', 'Member added successfully');
    } catch (e) {
      Logger.error('Failed to add member: $e');
      Get.snackbar('Error', 'Failed to add member');
    }
  }
}
