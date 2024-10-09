import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/transactions_view_controller.dart';

class TransactionsViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionViewModel>(() => TransactionViewModel());
  }
}
