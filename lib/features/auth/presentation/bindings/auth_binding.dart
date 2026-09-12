import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/setup_wizard_controller.dart';

/// Registered once at startup alongside CoreServicesBinding. Lazy + fenix
/// so these controllers are only actually built the first time a screen
/// needs them, and can be rebuilt if ever disposed.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SetupWizardController(), fenix: true);
  }
}