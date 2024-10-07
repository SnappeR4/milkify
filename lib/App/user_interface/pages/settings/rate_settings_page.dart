import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milkify/App/controllers/settings/rate_settings_controller.dart';

class RateSettingPage extends StatelessWidget {
  final RateSettingController rateController = Get.find<RateSettingController>();

  RateSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (rateController.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: rateController.products.length,
            itemBuilder: (context, index) {
              final product = rateController.products[index];
              final TextEditingController rateControllerField = TextEditingController(
                text: product.rate.toString(),
              );

              return Card(
                color: Colors.white,
                // margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: rateControllerField,
                        decoration: const InputDecoration(
                          labelText: 'Rate',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              double newRate = double.tryParse(rateControllerField.text) ?? 0.0;
                              rateController.updateRate(product.id, newRate);

                              Get.snackbar(
                                'Rate Updated',
                                '${product.name} rate updated to $newRate',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                            child: const Text('Update Rate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Get.offNamed('/settings'); // Navigate back to settings when done
      //   },
      //   label: const Text('Save & Exit'),
      //   icon: const Icon(Icons.save),
      // ),
    );
  }
}
