import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/controllers/collection_controller.dart';
import 'package:milkify/App/controllers/settings/member_settings_controller.dart';
import 'package:milkify/App/data/models/member_payment.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';
import 'package:milkify/App/utils/logger.dart';
class CollectionPage extends StatelessWidget {
  final MemberController memberController = Get.find<MemberController>();
  final CollectionController collectionController = Get.find<CollectionController>();
  CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () => memberController.isMemberSelectedPayment.value
              ? _buildSelectedMemberPaymentDetails() // Show selected member details if one is selected
              : Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16.0),
              Expanded(
                child: memberController.filteredMembers.isEmpty
                    ? MemberWidgets.buildEmptyListMessage()
                    : ListView.builder(
                  itemCount: memberController.filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = memberController.filteredMembers[index];
                    return MemberWidgets.buildMemberItem(
                      context: context,
                      member: member,
                      onTap: () {
                        memberController.selectMemberPayment(member); // Set selected member
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: memberController.searchMembers,
      decoration: InputDecoration(
        labelText: 'Search Members',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() {
          return memberController.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: memberController.clearSearch,
          )
              : Container();
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildSelectedMemberPaymentDetails() {
    final selectedMemberPayment = memberController.selectedMemberPayment;
    Logger.info(selectedMemberPayment.toString());
    collectionController.amountController = TextEditingController(text: "0.0");
    final remainingAmount = selectedMemberPayment['c_balance'];

    final List<MemberPayment> paymentTransactions = collectionController.payments.isNotEmpty
        ? collectionController.payments
        : [
      // MemberPayment(
      //   billNo: 1,
      //   memberId: selectedMemberPayment['m_id'],
      //   paidAmount: 500.0,
      //   currentBalance: 1000.0,
      //   date: DateTime.now().toIso8601String().split('T')[0],
      //   time: DateTime.now().toIso8601String().split('T')[1],
      // ),
      // MemberPayment(
      //   billNo: 2,
      //   memberId: selectedMemberPayment['m_id'],
      //   paidAmount: 300.0,
      //   currentBalance: 700.0,
      //   date: DateTime.now().toIso8601String().split('T')[0],
      //   time: DateTime.now().toIso8601String().split('T')[1],
      // ),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Member Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${DateFormat('dd-MM-yy').format(DateTime.now())}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    memberController.setMemberSelectedPayment(false); // Go back to member selection
                  },
                ),
              ],
            ),
            const Divider(),

            // Member Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${selectedMemberPayment['m_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: ${selectedMemberPayment['name']}'),
                Text('Phone: ${selectedMemberPayment['mobile_number']}'), // Assuming phone field exists
              ],
            ),
            const Divider(),

            // Remaining Balance and Amount Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remaining Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹$remainingAmount', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: collectionController.amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter amount'),
                        // onChanged: (value) {
                        //   // collectionController.updateAmount(); // Update amount when text changes
                        //   Logger.info("Update Amount in Controller");
                        // },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // Submit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    double paidAmount = double.parse(collectionController.amountController.text);
                    if (paidAmount == 0.0) {
                      Logger.warn('Paid amount cannot be 0');
                      Get.snackbar("Error", "Paid amount cannot be 0");
                      return;
                    }

                    // Save payment transaction
                    collectionController.savePayment(
                      memberId: selectedMemberPayment['m_id'],
                      paidAmount: paidAmount,
                      currentBalance: selectedMemberPayment['c_balance'],
                    );

                    Logger.info('Payment transaction submitted');
                    await Future.delayed(const Duration(seconds: 1));
                    memberController.setMemberSelectedPayment(false); // Close payment form
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            const Divider(),

            // Recent Payment Transactions
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Payments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  paymentTransactions.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true, // Allows ListView to fit within Column
                    physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll issues
                    itemCount: paymentTransactions.length,
                    itemBuilder: (context, index) {
                      final payment = paymentTransactions[index];
                      return ListTile(
                        title: Text('Bill No: ${payment.billNo}'),
                        subtitle: Text('Remaining: ₹${payment.currentBalance} | Paid: ₹${payment.paidAmount}'),
                        trailing: Text('₹${payment.paidAmount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    },
                  )
                      : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No payments', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
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
                memberController.deleteMember(member['m_id']);
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
