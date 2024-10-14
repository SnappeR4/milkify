import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/settings/member_settings_controller.dart';

class EditMemberPage extends StatelessWidget {
  EditMemberPage({super.key});

  final Map<String, dynamic> member =
      Get.arguments; // Get the member data passed to the page

  final MemberController memberSettingsController =
      Get.find<MemberController>();

  // Text controllers for editing member details
  final TextEditingController memberNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController recentlyPaidController = TextEditingController();
  final TextEditingController currentBalanceController =
      TextEditingController();
  final TextEditingController litersController = TextEditingController();

  // Dropdown values for milk type
  final List<String> milkTypes = ['Cow', 'Buffalo', 'Mix'];
  final RxString selectedMilkType = ''.obs;

  @override
  Widget build(BuildContext context) {
    // Pre-fill text controllers with member data
    memberNameController.text = member['name'] ?? '';
    mobileNumberController.text = member['mobile_number'] ?? '';
    addressController.text = member['address'] ?? '';
    recentlyPaidController.text = member['recently_paid'].toString();
    currentBalanceController.text = member['c_balance'].toString();
    litersController.text = member['liters'].toString();
    selectedMilkType.value = member['milk_type'] ?? 'Cow'; // Default to 'Cow'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNonEditableField('Member ID', member['m_id'].toString()),
              _buildTextField('Name', memberNameController, isMandatory: true),
              _buildTextField('Mobile Number', mobileNumberController,
                  isMandatory: true),
              _buildTextField('Address', addressController),
              _buildDropdownField('Milk Type', selectedMilkType),
              // Dropdown for milk type
              _buildTextField('Liters of Milk', litersController,
                  isMandatory: true),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateMember,
                child: const Text('Update Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to update member details with validation
  void _updateMember() {
    String name = memberNameController.text;
    String mobileNumber = mobileNumberController.text;
    String address = addressController.text;
    String litersText = litersController.text;

    if (name.isEmpty || selectedMilkType.value.isEmpty) {
      Get.snackbar('Error', 'Name and Milk Type are mandatory');
      return;
    }

    if (name.length > 30) {
      Get.snackbar('Error', 'Name cannot be more than 30 characters');
      return;
    }

    if (mobileNumber.length != 10) {
      Get.snackbar('Error', 'Mobile Number must be 10 digits');
      return;
    }

    if (address.length > 50) {
      Get.snackbar('Error', 'Address cannot be more than 50 characters');
      return;
    }

    double liters = double.tryParse(litersText) ?? 0.0;
    if (liters <= 0.0) {
      Get.snackbar('Error', 'Liters of Milk must be greater than 0.0');
      return;
    }

    // Prepare updated member data
    Map<String, dynamic> updatedMember = {
      'm_id': member['m_id'],
      'name': name,
      'mobile_number': mobileNumber,
      'address': address,
      'milk_type': selectedMilkType.value, // Updated milk type
      'recently_paid': double.tryParse(recentlyPaidController.text) ?? 0.00,
      'c_balance': double.tryParse(currentBalanceController.text) ?? 0.00,
      'liters': liters,
    };

    // Update the member in the controller
    memberSettingsController.editMember(updatedMember);
    Get.back(); // Go back after updating
  }

  // Dropdown for Milk Type selection
  Widget _buildDropdownField(String label, RxString selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => DropdownButtonFormField<String>(
            value: selectedValue.value.isNotEmpty ? selectedValue.value : null,
            items: milkTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: '$label *', // Mark milk type as mandatory
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                selectedValue.value = value;
              }
            },
          )),
    );
  }

  // Helper widget for building text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isMandatory ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        keyboardType: (label == 'Recently Paid' ||
                label == 'Current Balance' ||
                label == 'Liters of Milk')
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
      ),
    );
  }

  // Helper widget to build non-editable fields
  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: false,
      ),
    );
  }
}
