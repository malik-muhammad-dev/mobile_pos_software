import 'package:get/get.dart';
import '../controllers/customers_controller.dart';

class CustomersLedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomersController(), fenix: true);
  }
}