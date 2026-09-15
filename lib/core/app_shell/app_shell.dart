import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/subscription/presentation/widgets/subscription_banner.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_shell_controller.dart';
import 'nav_item.dart';

/// The persistent shell every logged-in screen lives inside: a left nav
/// rail filtered to the current role, plus the active screen's body.
/// Nothing in features/ should build its own nav chrome — it always lives
/// here, per the reused onims-hostel AppShell pattern.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppShellController());
    final session = Get.find<SessionService>();
    final staff = session.currentStaff.value;
    if (staff == null) return const SizedBox.shrink();

    final items = controller.itemsFor(staff.role);

    return Scaffold(
      body: Column(
        children: [
          const SubscriptionBanner(),
          Expanded(
            child: Obx(() {
              final selected = controller.selectedIndex.value.clamp(0, items.length - 1);
              return Row(
                children: [
                  _NavRail(
                    items: items,
                    selectedIndex: selected,
                    onSelect: controller.select,
                    staffName: staff.name,
                    onLogOut: controller.logOut,
                  ),
                  const VerticalDivider(width: 1, color: AppColors.borderDefault),
                  Expanded(child: items[selected].builder(context)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.staffName,
    required this.onLogOut,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String staffName;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Text(staffName, style: AppTypography.headlineSm, overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;
                  return ListTile(
                    leading: Icon(item.icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                    title: Text(
                      item.label,
                      style: AppTypography.bodyLg.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.06),
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textSecondary),
              title: const Text('Log Out', style: AppTypography.bodyLg),
              onTap: onLogOut,
            ),
          ],
        ),
      ),
    );
  }
}