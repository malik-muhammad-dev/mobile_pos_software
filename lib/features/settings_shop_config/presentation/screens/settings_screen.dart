import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/settings_controller.dart';
import '../widgets/backup_restore_card.dart';
import '../widgets/change_pin_dialog.dart';
import '../widgets/shop_profile_card.dart';

/// Owner-only. Shop profile + low-stock threshold, the logged-in owner's
/// own PIN, and backup visibility — no staff-management screen here, cut
/// from this build's scope per the original plan.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final session = Get.find<SessionService>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Obx(() {
        // Gates ShopProfileCard's construction on the real load finishing —
        // it seeds its text fields once, from whatever shopName/address
        // hold the moment it's first built, so building it before
        // SettingsController's async _load() completes would seed it with
        // blank values instead of the real saved shop config.
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: AppTypography.headlineLg),
              const SizedBox(height: AppSpacing.xs),
              const Text('Shop details, your PIN, and backups.', style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.lg),
              const ShopProfileCard(),
              const SizedBox(height: AppSpacing.gutter),
              Obx(() {
                final staff = session.currentStaff.value;
                return AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('My Account', style: AppTypography.headlineMd),
                            const SizedBox(height: AppSpacing.xs),
                            Text(staff?.name ?? '—', style: AppTypography.bodyLg),
                            const SizedBox(height: 2),
                            const Text('Owner', style: AppTypography.bodySm),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: AppButton(
                          label: 'Change PIN',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.lock_outline,
                          onPressed: () => Get.dialog(const ChangePinDialog()),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.gutter),
              BackupRestoreCard(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}