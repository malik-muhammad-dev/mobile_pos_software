import 'package:get/get.dart';
import '../services/auth_service.dart';

enum ColdStartState { loading, needsSetup, needsLogin }

/// Cold-start routing decision only: does any staff exist yet? AppRoot uses
/// this to choose Setup Wizard vs Login; once SessionService has a logged-in
/// staff, AppRoot switches straight to AppShell regardless of this state.
class AppRootController extends GetxController {
  final Rx<ColdStartState> state = ColdStartState.loading.obs;

  @override
  void onInit() {
    super.onInit();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final hasStaff = await Get.find<SqliteAuthService>().hasAnyStaff();
    state.value = hasStaff ? ColdStartState.needsLogin : ColdStartState.needsSetup;
  }
}