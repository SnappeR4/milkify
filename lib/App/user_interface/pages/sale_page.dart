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
      // appBar: AppBar(
      //   title: const Text('Members'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.add),
      //       onPressed: () {
      //         controller.generateNewMemberId();
      //         Get.toNamed(AppRoutes.addMember);
      //       },
      //     ),
      //   ],
      // ),
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

  Widget _buildSelectedMemberDetails() {
    final selectedMember = controller.selectedMember;
    Logger.info(selectedMember.toString());
    saleController.liters.value = selectedMember['liters'];
    saleController.litersController = TextEditingController(text: selectedMember['liters'].toString());
    final double rate = saleController.getRateForMilkType(selectedMember['milk_type']); // Fetch rate

// Use the transactions from the controller or fallback to default demo data
    final List<Transactions> transactions = saleController.transactions.isNotEmpty
        ? saleController.transactions
        : [
      Transactions(
        id: 0,
        receiptNo: '001',
        billType: '1',
        memberId: 1,
        productId: 1,
        productRate: 40.0,
        liters: 5.0,
        addOn: 0.0,
        total: 200.0,
        date: DateTime.now().toIso8601String().split('T')[0],
        time: DateTime.now().toIso8601String().split('T')[1],
        timestamp: DateTime.now().toString(),
        editedTimestamp: '',
        paymentMode: '0',
        paymentReceivedFlag: 0,
        memberOpeningBalance: 100.0,
        voidBillFlag: 0,
      ),
      Transactions(
        id: 0,
        receiptNo: '002',
        billType: '1',
        memberId: 2,
        productId: 1,
        productRate: 50.0,
        liters: 7.0,
        addOn: 0.0,
        total: 350.0,
        date: DateTime.now().toIso8601String().split('T')[0],
        time: DateTime.now().toIso8601String().split('T')[1],
        timestamp: DateTime.now().toString(),
        editedTimestamp: '',
        paymentMode: '0',
        paymentReceivedFlag: 0,
        memberOpeningBalance: 150.0,
        voidBillFlag: 0,
      ),
    ];
// final transactions =[
//   {'name': 'John Doe', 'm_id': '001', 'liters': 5.0, 'rate': 40.0},
//       {'name': 'Jane Smith', 'm_id': '002', 'liters': 7.0, 'rate': 50.0},];

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
            // Date and Milk Type Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${DateFormat('dd-MM-yy').format(DateTime.now())}', style: const TextStyle(fontSize: 16)),
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
                    Text('ID: ${selectedMember['m_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Name: ${selectedMember['name']}'),
                    Text('Phone: ${selectedMember['mobile_number']}'), // Assuming phone field exists
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
              final rate = saleController.getRateForMilkType(selectedMember['milk_type']); // or whichever milk type
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Liters', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: saleController.litersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter liters'),
                          onChanged: (value) {
                            saleController.updateLiters(); // Update liters when text changes
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
                        const Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹$rate', style: const TextStyle(fontSize: 16)), // Rate fetched from controller
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
                    child: Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child:Obx(() { return Text('₹${(saleController.liters * rate).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.right);
                    }),
                  ),
                ],
              ),
              const Divider(),

              // Recent Transactions List
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Transactions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  transactions.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true, // Allows ListView to fit within Column
                    physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll issues
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return ListTile(
                        title: Text('Receipt No: ${transaction.receiptNo}'),
                        subtitle: Text('Liters: ${transaction.liters} | Rate: ₹${transaction.productRate}'),
                        trailing: Text('₹${transaction.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        onTap: (){
                          _showEditTransactionDialog(context,transaction);
                        },
                      );
                    },
                  )
                      : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No transactions', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                        double liters = saleController.liters.value;
                        if (liters == 0.0 || rate == 0.0) {
                          // Show error if input is invalid
                          Logger.warn('Liters or rate cannot be 0');
                          Get.snackbar("Error", "Liters or rate cannot be 0");
                          return;
                        }
                        double total = liters * rate;
                        controller.submitTransaction(selectedMember, liters, rate, total);
                        await Future.delayed(const Duration(seconds: 1));
                        Logger.info('Transaction submitted');
                        controller.setMemberSelected(false);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ]
      )
    ));
  }

  // Show a popup dialog when a transaction is tapped
  void _showEditTransactionDialog(BuildContext context, Transactions transaction) {
    TextEditingController litersController = TextEditingController(text: transaction.liters.toString());

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
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the new liters value
                double newLiters = double.tryParse(litersController.text) ?? 0.0;

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
                  saleController.updateTransaction(transaction.receiptNo, transaction.date, newLiters, productRate);

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