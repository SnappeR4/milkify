import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:milkify/App/controllers/sale_controller.dart';
import 'package:milkify/App/controllers/settings/member_settings_controller.dart';
import 'package:milkify/App/data/models/transaction.dart';
import 'package:milkify/App/user_interface/widgets/member_widgets.dart';
import 'package:milkify/App/utils/logger.dart';

class SalePage extends StatelessWidget {
  final MemberController controller = Get.find<MemberController>();
  final SaleController saleController = Get.find<SaleController>();

  SalePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                final member =
                                    controller.filteredMembers[index];
                                return MemberWidgets.buildMemberItem(
                                  context: context,
                                  member: member,
                                  onTap: () {
                                    controller.selectMember(
                                        member); // Set selected member
                                  },
                                  onDelete: () => Get.snackbar('Member Delete',
                                      'No Deletion on this Page'),
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
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  controller.scanQrCode(true);
                },
              ),
              controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              )
                  : Container(),
            ],
          );
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }


  Widget _buildSelectedMemberDetails() {
    saleController.fetchProductRatesFromDB();
    final selectedMember = controller.selectedMember;
    Logger.info(selectedMember.toString());
    saleController.liters.value = selectedMember['liters'];
    saleController.litersController =
        TextEditingController(text: selectedMember['liters'].toString());
    saleController.onScreenMilkRate.value = saleController
        .getRateForMilkType(selectedMember['milk_type']); // Fetch rate
    final List<Transactions> transactions =
        saleController.transactions.isNotEmpty
            ? saleController.transactions
            : [];

    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Date and Milk Type Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${DateFormat('dd-MM-yy').format(DateTime.now())}',
                  style: const TextStyle(fontSize: 16)),
              MemberWidgets.buildMilkTypeIcon(selectedMember['milk_type'])
            ],
          ),
          const Divider(),
          // Member Details and Search Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${selectedMember['m_id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Name: ${selectedMember['name']}'),
                  Text('Phone: ${selectedMember['mobile_number']}'),
                  // Assuming phone field exists
                ],
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.setMemberSelected(false);
                },
              ),
            ],
          ),
          const Divider(),

          // Liters and Rate Input
          Obx(() {
            saleController.loadSettings();
            saleController.onScreenMilkRate.value = saleController.getRateForMilkType(
                selectedMember['milk_type']);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Liters',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: saleController.litersController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter liters'),
                        onChanged: (value) {
                          saleController
                              .updateLiters(); // Update liters when text changes
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rate',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      if(saleController.rateSetting.value!=0){
                        _showRateDialog(selectedMember['milk_type'], saleController.onScreenMilkRate.value);
                      }else{
                        Get.snackbar("Rate Edit", "Enable Settings");
                      }
                    },
                    child: Obx(() {
                      return Text(
                        '₹${saleController.onScreenMilkRate.value}',
                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                      );
                    }),),
                      // Rate fetched from controller
                    ],
                  ),
                ),
              ],
            );
          }),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Calculation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Total:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Obx(() {
                      return Text(
                          '₹${(saleController.liters * saleController.onScreenMilkRate.value).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right);
                    }),
                  ),
                ],
              ),
              const Divider(),

              // Recent Transactions List
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Transactions:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  transactions.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          // Allows ListView to fit within Column
                          physics: const NeverScrollableScrollPhysics(),
                          // Prevents nested scroll issues
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return ListTile(
                              title:
                                  Text('Receipt No: ${transaction.receiptNo}'),
                              subtitle: Text(
                                  'M ID: ${transaction.memberId} | Liters: ${transaction.liters} | Rate: ₹${transaction.productRate}'),
                              trailing: Text(
                                '₹${transaction.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                _showEditTransactionDialog(
                                    context, transaction);
                              },
                            );
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No transactions',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                ],
              ),
              const Divider(),

              // Reset and Submit Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //   onPressed: () {
                  //     saleController.liters.value = 0.0;
                  //     Logger.info('Fields reset');
                  //   },
                  //   child: const Text('Reset'),
                  // ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (saleController.isSubmitting.value) return;

                        saleController.isSubmitting.value = true;
                        double liters = saleController.liters.value;
                        if (liters == 0.0 || saleController.onScreenMilkRate.value == 0.0) {
                          // Show error if input is invalid
                          Logger.warn('Liters or rate cannot be 0');
                          Get.snackbar("Error", "Liters or rate cannot be 0");
                          return;
                        }
                        double total = liters * saleController.onScreenMilkRate.value;
                        controller.submitTransaction(
                            selectedMember, liters, saleController.onScreenMilkRate.value, total);
                        await Future.delayed(const Duration(seconds: 1));
                        await controller.syncMembers();
                        Logger.info('Transaction submitted');
                        saleController.isSubmitting.value = false;
                        controller.setMemberSelected(false);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ])));
  }

  // Show a popup dialog when a transaction is tapped
  void _showEditTransactionDialog(
      BuildContext context, Transactions transaction) {
    TextEditingController litersController =
        TextEditingController(text: transaction.liters.toString());
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Transaction - ${transaction.receiptNo}'),
          content: TextField(
            controller: litersController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Liters'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String editTime = formatter.format(now);
                SaleController.deleteTransaction(
                    transaction.receiptNo, transaction.date, editTime);
                saleController.fetchTransactions();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the new liters value
                double newLiters =
                    double.tryParse(litersController.text) ?? 0.0;

                // Validate that the entered liters are greater than 0
                if (newLiters <= 0) {
                  // Show an error message if the liters are not valid
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Invalid Input'),
                      content: const Text('Liters must be greater than 0.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the error dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Assuming you have a way to get the product rate (e.g., stored in a variable)
                  double productRate = transaction.productRate;

                  // Call the update method to update the transaction in the database
                  saleController.updateTransaction(
                      transaction.receiptNo,
                      transaction.date,
                      newLiters,
                      productRate,
                      formatter.format(now));

                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
// Method to show the rate input dialog
  void _showRateDialog(String milkType, double currentRate) {
    final TextEditingController rateController = TextEditingController();
    rateController.text = currentRate.toString(); // Pre-fill with current rate

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Set Rate'),
        content: TextField(
          controller: rateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter rate'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(rateController.text);
              if (newRate != null) {
                saleController.onScreenMilkRate.value = newRate; // Update the rate in the controller
                Get.back(); // Close the dialog
              }
            },
            child: const Text('Set Rate'),
          ),
        ],
      ),
    );
  }
}
