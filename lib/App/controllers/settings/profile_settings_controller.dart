// lib/app/controllers/settings/profile_settings_controller.dart
import 'dart:io'; // for File handling
import 'package:get/get.dart';
import 'package:milkify/App/data/models/profile_model.dart';
import 'package:milkify/App/data/services/database_helper.dart';

class ProfileSettingsController extends GetxController {
  var profile = Profile().obs;
  var profileImage = Rxn<File>(); // To hold the profile image
  var isEditing = false.obs;
  final dbHelper = DatabaseHelper.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    Profile? storedProfile = await dbHelper.getProfile();
    if (storedProfile != null) {
      profile.value = storedProfile;
      if (storedProfile.imagePath != null) {
        profileImage.value =
            File(storedProfile.imagePath!); // Load the saved image
      }
      isEditing.value = true;
    }
  }

  void setProfileImage(File imageFile) {
    profileImage.value = imageFile; // Set the selected image
  }

  Future<void> saveProfile(String brandName, String mobileNumber) async {
    Profile newProfile = Profile(
      brandName: brandName,
      mobileNumber: mobileNumber,
      imagePath: profileImage.value?.path, // Save image path
    );

    if (isEditing.value) {
      await dbHelper.updateProfile(newProfile);
      Get.snackbar("Profile", "Updated Successfully");
    } else {
      await dbHelper.insertProfile(newProfile);
      Get.snackbar("Profile", "Inserted Successfully");
    }
    profile.value = newProfile;
  }
}
