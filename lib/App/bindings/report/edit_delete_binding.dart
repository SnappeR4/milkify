import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/edit_delete_transactions_controller.dart';
class EditDeleteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditDeleteTransactionsController>(() => EditDeleteTransactionsController());
  }
}