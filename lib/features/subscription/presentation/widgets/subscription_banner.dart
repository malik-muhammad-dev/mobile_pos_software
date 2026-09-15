import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'submit_payment_dialog.dart';

/// A thin strip above the AppShell nav+content row — renewal reminder,
/// overdue warning, or "payment under review", depending on where the
/// subscription stands. Self-contained Obx so AppShell doesn't need to
/// know anything about subscription state to place this correctly.
class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();

    return Obx(() {
      if (subscription.paymentPendingReview.value) {
        return _Bar(
          icon: Icons.hourglass_top,
          ink: AppColors.primary,
          bg: AppColors.primary.withValues(alpha: 0.08),
          message: "Payment submitted — waiting on review.",
        );
      }
      if (subscription.showsOverdueWarning) {
        return _Bar(
          icon: Icons.error_outline,
          ink: AppColors.danger,
          bg: AppColors.dangerBg,
          message: 'Subscription payment is overdue. The app locks in '
              '${subscription.daysUntilLockout} day${subscription.daysUntilLockout == 1 ? '' : 's'} '
              'if payment isn\'t submitted.',
          actionLabel: 'Submit Payment',
        );
      }
      if (subscription.showsRenewalReminder) {
        return _Bar(
          icon: Icons.info_outline,
          ink: AppColors.warning,
          bg: AppColors.warningBg,
          message: 'Subscription renews in ${subscription.daysUntilDue} '
              'day${subscription.daysUntilDue == 1 ? '' : 's'}.',
          actionLabel: 'Submit Payment',
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.icon,
    required this.ink,
    required this.bg,
    required this.message,
    this.actionLabel,
  });

  final IconData icon;
  final Color ink;
  final Color bg;
  final String message;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ink),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTypography.bodyMd.copyWith(color: ink)),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: () => Get.dialog(const SubmitPaymentDialog()),
              style: TextButton.styleFrom(foregroundColor: ink),
              child: Text(actionLabel!, style: AppTypography.labelLg.copyWith(color: ink)),
            ),
        ],
      ),
    );
  }
}