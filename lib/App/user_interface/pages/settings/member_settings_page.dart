import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/settings/member_settings_controller.dart';
import 'package:milkify/App/routes/app_routes.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';

class MemberListPage extends StatelessWidget {
  final controller = Get.find<MemberController>();

  MemberListPage({super.key});

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
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'Import') {
                controller.importMembers();
              } else if (value == 'Export') {
                controller.exportMembers();
              } else if (value == 'Export All QR') {
                controller.exportAllQrCodes(); // Call the new export QR method
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'Import',
                child: Text('Import Members'),
              ),
              const PopupMenuItem<String>(
                value: 'Export',
                child: Text('Export Members'),
              ),
              const PopupMenuItem<String>(
                value: 'Export All QR',
                child: Text('Export All QR Codes'),
              ),
            ],
            icon: const Icon(Icons.more_vert), // Three vertical dot icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            Expanded(
              child: Obx(
                () => controller.filteredMembers.isEmpty
                    ? MemberWidgets.buildEmptyListMessage()
                    : ListView.builder(
                        itemCount: controller.filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = controller.filteredMembers[index];
                          return MemberWidgets.buildMemberItem(
                            context: context,
                            member: member,
                            onTap: () => Get.toNamed(AppRoutes.editMember,
                                arguments: member),
                            onDelete: () => _confirmDelete(context, member),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _confirmDelete(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
