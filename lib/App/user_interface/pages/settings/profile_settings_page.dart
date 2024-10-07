import 'dart:io'; // for File handling
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milkify/App/controllers/settings/profile_settings_controller.dart';

class ProfileSettingsPage extends StatelessWidget {
  final ProfileSettingsController profileController = Get.find<ProfileSettingsController>();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  // Image Picker instance
  final ImagePicker _picker = ImagePicker();

  ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Obx(() {
        // Load profile data into the form if available
        if (profileController.isEditing.value) {
          brandNameController.text = profileController.profile.value.brandName ?? '';
          mobileNumberController.text = profileController.profile.value.mobileNumber ?? '';
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile image section with edit option
              GestureDetector(
                onTap: () async {
                  // Pick image from gallery
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    profileController.setProfileImage(File(pickedFile.path)); // Set image in controller
                  }
                },
                child: Obx(() {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: profileController.profileImage.value != null
                        ? FileImage(profileController.profileImage.value!) as ImageProvider
                        : const AssetImage('assets/images/default_profile.jpeg'), // Default image
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: brandNameController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
              ),
              TextField(
                controller: mobileNumberController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  profileController.saveProfile(
                    brandNameController.text,
                    mobileNumberController.text,
                  );
                  Get.back();
                },
                child: Text(profileController.isEditing.value ? 'Update Profile' : 'Save Profile'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
