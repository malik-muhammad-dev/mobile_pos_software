import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/staff_model.dart';

enum ColdStartState { loading, needsSetup, needsLogin }

/// Cold-start routing decision: does any staff exist yet? AppRoot uses this
/// to choose Setup Wizard vs Login; once SessionService has a logged-in
/// staff, AppRoot switches straight to AppShell regardless of this state.
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
    // Held to a minimum visible duration so the splash screen actually
    // registers instead of flashing past in a few milliseconds on a fast
    // local database check.
    final results = await Future.wait([
      Get.find<SqliteAuthService>().hasAnyStaff(),
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    final hasStaff = results[0] as bool;
    state.value = hasStaff ? ColdStartState.needsLogin : ColdStartState.needsSetup;
  }
}