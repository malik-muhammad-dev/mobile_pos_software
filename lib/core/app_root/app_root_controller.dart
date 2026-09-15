import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/shop_account_service.dart';
import '../services/staff_model.dart';

enum ColdStartState { loading, needsShopAccount, needsSetup, needsLogin }

/// Cold-start routing decision, in order: is this device tied to a shop
/// account at all (Supabase session)? If not, that's the very first thing
/// needed — new shop or reactivating an existing one. Once a shop account
/// exists, does any local staff exist yet? That picks Setup Wizard vs
/// Login. Once SessionService has a logged-in staff, AppRoot switches
/// straight to AppShell (or the subscription lock screen) regardless of
/// this state.
class AppRootController extends GetxController {
  final Rx<ColdStartState> state = ColdStartState.loading.obs;

  @override
  void onInit() {
    super.onInit();
    _checkFirstRun();

    // Once someone has ever logged in, staff definitely exist — any future
    // logout must land on Login, never fall back to Setup Wizard's stale
    // (and possibly mid-step) leftover state.
    ever<Staff?>(Get.find<SessionService>().currentStaff, (staff) {
      if (staff == null) {
        state.value = ColdStartState.needsLogin;
      }
    });
  }

  Future<void> _checkFirstRun() async {
    final hasShopSession = Get.find<ShopAccountService>().hasSession;

    // Held to a minimum visible duration so the splash screen actually
    // registers instead of flashing past in a few milliseconds on a fast
    // local database check.
    final results = await Future.wait([
      Get.find<SqliteAuthService>().hasAnyStaff(),
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    final hasStaff = results[0] as bool;

    if (!hasShopSession) {
      state.value = ColdStartState.needsShopAccount;
      return;
    }
    state.value = hasStaff ? ColdStartState.needsLogin : ColdStartState.needsSetup;
  }

  /// Called once ShopAccountScreen finishes registering or reactivating —
  /// re-runs the same check now that a Supabase session exists, so AppRoot
  /// moves on to Setup Wizard or Login.
  Future<void> onShopAccountResolved() => _checkFirstRun();
}