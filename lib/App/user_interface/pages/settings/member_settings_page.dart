// lib/app/pages/member_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings/member_settings_controller.dart';
import '../../../routes/app_routes.dart';
import '../../themes/app_theme.dart';

class MemberListPage extends StatelessWidget {
  MemberListPage({super.key});

  final MemberController controller = Get.find<MemberController>();

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
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            Expanded(
              child: Obx(
                    () => controller.filteredMembers.isEmpty
                    ? _buildEmptyListMessage()
                    : ListView.builder(
                  itemCount: controller.filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = controller.filteredMembers[index];
                    return _buildMemberItem(context, member);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search bar widget with clear button
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

  // Message when the list is empty
  Widget _buildEmptyListMessage() {
    return Center(
      child: Text(
        'No members found',
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
    );
  }

  // Member list item widget
  // Widget _buildMemberItem(BuildContext context, Map<String, dynamic> member) {
  //   return Card(
  //     elevation: 10,
  //     margin: const EdgeInsets.symmetric(vertical: 8.0),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //     child: ListTile(
  //       onTap: () => Get.toNamed(AppRoutes.editMember, arguments: member),
  //       title: Text(
  //         member['name'], // Matches the "name" field in your SQL table
  //         style: Theme.of(context).textTheme.titleMedium!.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'ID: ${member['m_id']}', // Matches the "m_id" field in your SQL table
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //           Text(
  //             'Mobile: ${member['mobile_number']}', // Matches the "mobile_number" field in your SQL table
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //           // Text(
  //           //   'Recently Paid: ₹${member['recently_paid']}', // Matches the "recently_paid" field
  //           //   style: Theme.of(context).textTheme.bodyMedium,
  //           // ),
  //           Text(
  //             'Balance: ₹${member['c_balance']}', // Matches the "c_balance" field
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //           Text(
  //             'Milk Type: ${member['milk_type']}', // Matches the "milk_type" field
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //           Text(
  //             'Liters: ${member['liters']}', // Matches the "liters" field
  //             style: Theme.of(context).textTheme.bodyMedium,
  //           ),
  //         ],
  //       ),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.delete, color: Colors.redAccent),
  //         onPressed: () => _confirmDelete(context, member),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMemberItem(BuildContext context, Map<String, dynamic> member) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.editMember, arguments: member),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // // Icon or Avatar representing the member
              // CircleAvatar(
              //   radius: 25,
              //   backgroundColor: Colors.blueAccent.withOpacity(0.1),
              //   child: Icon(Icons.person, size: 30, color: Colors.blueAccent),
              // ),
              // const SizedBox(width: 16.0),

              // Member information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Name and ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          member['name'], // Name of the member
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'ID: ${member['m_id']}', // Member ID
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),

                    // Mobile number
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 8.0),
                        Text(
                          member['mobile_number'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),

                    // Balance
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 18, color: Colors.green),
                        const SizedBox(width: 8.0),
                        Text(
                          'Balance: ₹${member['c_balance'].toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),

                    // Milk Type and Liters
                    Row(
                      children: [
                        const Icon(Icons.local_drink, size: 18, color: Colors.brown),
                        const SizedBox(width: 8.0),
                        Text(
                          '${member['milk_type']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16.0),
                        const Icon(Icons.opacity, size: 18, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Text(
                          '${member['liters'].toStringAsFixed(2)} Liters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, member),
                tooltip: 'Delete Member',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete confirmation dialog
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
