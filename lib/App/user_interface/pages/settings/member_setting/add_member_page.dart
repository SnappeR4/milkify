import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/settings/member_setting/add_member_controller.dart';
import '../../../../controllers/settings/member_settings_controller.dart';
import '../../../../utils/logger.dart';

// ignore: must_be_immutable
class AddMemberPage extends StatelessWidget {
  AddMemberPage({super.key});

  final AddMemberController controller = Get.put(AddMemberController());

  final MemberController memberSettingsController = Get.find<MemberController>();

  // Text controllers to capture user input
  final TextEditingController memberNameController = TextEditingController();

  final TextEditingController mobileNumberController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController currentBalanceController = TextEditingController(text: '0.00');

  final TextEditingController litersController = TextEditingController(text: '0.0');

  // Dropdown values for milk type
  final List<String> milkTypes = ['Cow', 'Buffalo', 'Mix'];

  String selectedMilkType = 'Cow';

  // GlobalKey to reference the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              children: [
                _buildNonEditableField('Member ID', memberSettingsController.newMemberId.value),
                _buildTextField('Name', memberNameController, isMandatory: true, maxLength: 30),
                _buildTextField('Mobile Number', mobileNumberController, isMandatory: true, maxLength: 10, isNumeric: true),
                _buildTextField('Address', addressController, maxLength: 50),
                _buildMilkTypeDropdown(), // Dropdown for milk type
                _buildTextField('Deposit', currentBalanceController, isNumeric: true),
                _buildTextField('Liters of Milk', litersController, isMandatory: true, isNumeric: true, minValue: 0.01),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveMember,
                  child: const Text('Save Member'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to save a new member
  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      // Prepare member data
      Map<String, dynamic> newMember = {
        'm_id': memberSettingsController.newMemberId.value,
        'name': memberNameController.text,
        'mobile_number': mobileNumberController.text,
        'address': addressController.text,
        'milk_type': selectedMilkType, // Use the selected milk type
        'recently_paid': double.tryParse(currentBalanceController.text) ?? 0.00,
        'c_balance': double.tryParse(currentBalanceController.text) ?? 0.00,
        'liters': double.tryParse(litersController.text) ?? 0.00,
      };
      Logger.info(newMember.toString());
      controller.addMember(newMember); // Use the AddMemberController
      Get.back(); // Go back after saving
    }
  }

  // Helper widget to build text fields with validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isMandatory = false, int? maxLength, bool isNumeric = false, double? minValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isMandatory ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLength: maxLength,
        validator: (value) {
          if (isMandatory && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (maxLength != null && value != null && value.length > maxLength) {
            return 'Must be less than $maxLength characters';
          }
          if (label == 'Mobile Number' && value != null && !RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Enter a valid 10-digit mobile number';
          }
          if (label == 'Liters of Milk' && value != null && (double.tryParse(value) == null || double.parse(value) <= 0.0)) {
            return 'Liters must be greater than 0';
          }
          return null; // Return null if validation passes
        },
      ),
    );
  }

  // Helper widget to show non-editable fields
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

  // Helper widget to build milk type dropdown
  Widget _buildMilkTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedMilkType, // Initial value
        items: milkTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? newValue) {
          selectedMilkType = newValue!;
        },
        decoration: const InputDecoration(
          labelText: 'Milk Type (cow, buffalo, mix) *',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a milk type';
          }
          return null;
        },
      ),
    );
  }
}
