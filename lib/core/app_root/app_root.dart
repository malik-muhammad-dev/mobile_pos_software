import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/setup_wizard_screen.dart';
import '../app_shell/app_shell.dart';
import '../services/session_service.dart';
import 'app_root_controller.dart';

/// First widget shown after startup. Decides between Setup Wizard, Login,
/// or the AppShell based on whether any staff exist yet and who — if
/// anyone — is currently logged in at this terminal.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppRootController());
    final session = Get.find<SessionService>();

    return Obx(() {
      if (session.isLoggedIn) return const AppShell();

      switch (controller.state.value) {
        case ColdStartState.loading:
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        case ColdStartState.needsSetup:
          return const SetupWizardScreen();
        case ColdStartState.needsLogin:
          return const LoginScreen();
      }
    });
  }
}