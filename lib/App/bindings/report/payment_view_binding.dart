import 'package:get/get.dart';
import 'package:milkify/App/controllers/report/payment_view_controller.dart';
class PaymentViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentViewController>(() => PaymentViewController());
  }
}
