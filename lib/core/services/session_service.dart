import 'package:get/get.dart';
import 'staff_model.dart';

/// Who's currently logged in at this terminal. AppShell reads `role` to
/// decide which nav items exist at all — a Cashier-hidden feature must be
/// genuinely absent, not just disabled, so screens should check this
/// rather than trusting that a route simply wasn't linked to.
class SessionService extends GetxService {
  final Rxn<Staff> currentStaff = Rxn<Staff>();

  bool get isLoggedIn => currentStaff.value != null;
  StaffRole? get role => currentStaff.value?.role;
  bool get isOwner => role == StaffRole.owner;

  void logIn(Staff staff) => currentStaff.value = staff;

  void logOut() => currentStaff.value = null;
}