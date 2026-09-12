import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_shell/app_shell.dart';
import '../services/session_service.dart';
import '../widgets/coming_soon_screen.dart';
import 'app_root_controller.dart';

/// First widget shown after startup. Decides between Setup Wizard, Login,
/// or the AppShell — the actual Setup/Login screen content comes later
/// (placeholders for now, per "core only" scope for this pass).
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
          return const Scaffold(body: ComingSoonScreen(title: 'Setup Wizard'));
        case ColdStartState.needsLogin:
          return const Scaffold(body: ComingSoonScreen(title: 'Login'));
      }
    });
  }
}