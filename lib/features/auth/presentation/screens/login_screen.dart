import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/pin_entry_step.dart';
import '../widgets/staff_picker.dart';

/// Every-day entry point: pick who you are, then type your PIN. No
/// username, no email — just this, every time the app opens.
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
      if (selected == null) {
        return AuthScaffold(
          title: controller.shopName.value,
          subtitle: 'Who is logging in?',
          child: StaffPicker(
            staff: controller.staffList,
            onSelect: controller.selectStaff,
          ),
        );
      }

      return PinEntryStep(
        title: 'Welcome, ${selected.name}',
        subtitle: 'Enter your PIN',
        pinController: controller.pinController,
        onCompleted: controller.submitPin,
        onBack: controller.backToStaffList,
        backLabel: 'Not you?',
      );
    });
  }
}