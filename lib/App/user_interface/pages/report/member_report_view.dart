import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/member_report_controller.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';

class MemberReportPage extends StatelessWidget {
  final MemberReportController controller = Get.find<MemberReportController>();

  MemberReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isMemberSelected.value) {
            final selectedMember = controller.selectedMember;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${selectedMember['m_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Name: ${selectedMember['name']}'),
                        Text('Phone: ${selectedMember['mobile_number']}'),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        controller.setMemberSelected(false); // Deselect the member
                      },
                    ),
                  ],
                ),
                const Divider(),
                _buildMemberLedgerDetails(),
                const Divider(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar('PDF Print', 'Print PDF button clicked!'); // For debugging
                    },
                    child: const Text('Member Ledger PDF'),
                  ),
                ),
              ],
            );
          } else {
            return Column(
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
                        onDelete: () => Get.snackbar('Member Delete', 'No Deletion on this Page'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search members',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        controller.searchMembers(value);
      },
    );
  }

  Widget _buildMemberLedgerDetails() {
    final selectedMember = controller.selectedMember;
    return Column(
      children: [
        // FutureBuilder for Total Paid Amount
        FutureBuilder<double>(
          future: controller.getTotalPaidAmount(selectedMember['m_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching total paid amount');
            } else {
              return _buildLedgerRow('Total Paid Amount', snapshot.data?.toString() ?? '0.0');
            }
          },
        ),

        // FutureBuilder for Total Bill Amount
        FutureBuilder<double>(
          future: controller.getTotalBillAmount(selectedMember['m_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching total bill amount');
            } else {
              return _buildLedgerRow('Total Bill Amount', snapshot.data?.toString() ?? '0.0');
            }
          },
        ),
      ],
    );
  }
  // Column(
  // children: [
  // // Opening Balance
  // // _buildLedgerRow(
  // //   'Opening Balance',
  // //   selectedMember['m_id'].toString(),
  // // ),
  // // Total Paid Amount
  // _buildLedgerRow(
  // 'Total Paid Amount',
  // controller.getTotalPaidAmount(selectedMember['m_id']).toString(),
  // ),
  // // Total Bill Amount
  // _buildLedgerRow(
  // 'Total Bill Amount',
  // controller.getTotalBillAmount(selectedMember['m_id']).toString(),
  // ),
  // // Current Balance
  // _buildLedgerRow(
  // 'Current Balance',
  // selectedMember['c_balance'].toString(),
  // ),
  // ],
  // );
  Widget _buildLedgerRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
