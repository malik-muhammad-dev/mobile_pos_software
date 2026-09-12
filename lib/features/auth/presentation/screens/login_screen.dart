import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_shell.dart';
import '../widgets/initial_avatar.dart';
import '../widgets/login_staff_step.dart';
import '../widgets/pin_entry_step.dart';

/// Every-day entry point: pick who you are, then type your PIN. No
/// username, no email — just this, every time the app opens. One split
/// screen the whole time; only the right-hand content changes.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final selected = controller.selectedStaff.value;
      return AuthShell(
        brand: AuthBrandPanel(title: controller.shopName.value, subtitle: 'Point of Sale'),
        content: selected == null
            ? LoginStaffStep(staff: controller.staffList, onSelect: controller.selectStaff)
            : PinEntryStep(
                title: 'Welcome, ${selected.name}',
                subtitle: 'Enter your PIN',
                leading: InitialAvatar(name: selected.name, size: 72),
                pinController: controller.pinController,
                onCompleted: controller.submitPin,
                onBack: controller.backToStaffList,
                backLabel: 'Not you?',
              ),
      );
    });
  }
}