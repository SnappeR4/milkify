import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/sale_controller.dart';
import 'package:milkify/App/controllers/settings/member_settings_controller.dart';
import 'package:milkify/App/data/models/member.dart';
import 'package:milkify/App/routes/app_routes.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';
import 'package:milkify/App/utils/logger.dart';

class SalePage extends StatelessWidget {
  final MemberController controller = Get.put(MemberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              controller.generateNewMemberId();
              Get.toNamed(AppRoutes.addMember);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () => controller.isMemberSelected.value
              ? _buildSelectedMemberDetails() // Show selected member details if one is selected
              : Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16.0),
              Expanded(
                child: controller.filteredMembers.isEmpty
                    ? MemberWidgets.buildEmptyListMessage()
                    : ListView.builder(
                  itemCount: controller.filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = controller.filteredMembers[index];
                    return MemberWidgets.buildMemberItem(
                      context: context,
                      member: member,
                      onTap: () {
                        controller.selectMember(member); // Set selected member
                      },
                      onDelete: () => _confirmDelete(context, member),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build search bar widget
  Widget _buildSearchBar() {
    return TextField(
      onChanged: controller.searchMembers,
      decoration: InputDecoration(
        labelText: 'Search Members',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() {
          return controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearSearch,
          )
              : Container();
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  // Build selected member details container
  Widget _buildSelectedMemberDetails() {
    final selectedMember = controller.selectedMember;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16.0),
          Text('Name: ${selectedMember['name']}'),
          Text('ID: ${selectedMember['m_id']}'),
          // Display more member details as needed
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Navigate to sale collection page
              // Get.toNamed(AppRoutes.saleCollection, arguments: selectedMember);
              Logger.info("Sale Collections page");
            },
            child: const Text('Proceed to Sale Collection'),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog for member deletion
  void _confirmDelete(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: Text('Are you sure you want to delete ${member['name']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteMember(member['m_id']);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}