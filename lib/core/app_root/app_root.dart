import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/setup_wizard_screen.dart';
import '../../features/shop_account/presentation/screens/shop_account_screen.dart';
import '../../features/subscription/presentation/screens/subscription_locked_screen.dart';
import '../app_shell/app_shell.dart';
import '../services/session_service.dart';
import '../services/subscription_service.dart';
import '../widgets/splash_screen.dart';
import 'app_root_controller.dart';

/// First widget shown after startup. Decides, in order: does this device
/// have a shop account yet (Shop Account screen if not), does any local
/// staff exist yet (Setup Wizard vs Login), and once someone's logged in,
/// is the subscription locked (lock screen instead of the shell).
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppRootController());
    final session = Get.find<SessionService>();
    final subscription = Get.find<SubscriptionService>();

    return Obx(() {
      if (session.isLoggedIn) {
        // Hard lock: even a logged-in staff member can't reach the shell
        // once the grace window has run out — Log Out is still reachable
        // from the lock screen itself.
        return subscription.isLocked ? const SubscriptionLockedScreen() : const AppShell();
      }

      switch (controller.state.value) {
        case ColdStartState.loading:
          return const SplashScreen();
        case ColdStartState.needsShopAccount:
          return const ShopAccountScreen();
        case ColdStartState.needsSetup:
          return const SetupWizardScreen();
        case ColdStartState.needsLogin:
          return const LoginScreen();
      }
    });
  }
}