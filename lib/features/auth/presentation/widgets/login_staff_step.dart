import 'package:flutter/material.dart';
import '../../../../core/services/staff_model.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'staff_picker.dart';

/// Login's first state: "who's working today?" plus the tappable staff
/// list. Picking a name morphs this same panel into the PIN step —
/// nothing navigates anywhere.
class LoginStaffStep extends StatelessWidget {
  const LoginStaffStep({super.key, required this.staff, required this.onSelect});

  final List<Staff> staff;
  final ValueChanged<Staff> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Who is logging in?', style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.xl),
        StaffPicker(staff: staff, onSelect: onSelect),
      ],
    );
  }
}