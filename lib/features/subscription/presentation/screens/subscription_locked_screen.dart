import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/submit_payment_dialog.dart';

/// Shown instead of AppShell whenever SubscriptionService.isLocked is
/// true — full hard lock, nothing behind it is reachable. The reason
/// varies (awaiting initial approval, overdue, payment under review, an
/// unverifiable status, or a tampered clock) and each gets its own plain-
/// language explanation rather than one generic "expired" message.
class SubscriptionLockedScreen extends StatelessWidget {
  const SubscriptionLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_outline, size: 36, color: AppColors.danger),
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(() => Text(_headline(subscription), style: AppTypography.headlineLg, textAlign: TextAlign.center)),
                const SizedBox(height: AppSpacing.sm),
                Obx(() => Text(_body(subscription), style: AppTypography.bodyLg, textAlign: TextAlign.center)),
                const SizedBox(height: AppSpacing.xl),
                Obx(() {
                  if (!_showsSubmitButton(subscription)) return const SizedBox.shrink();
                  return SizedBox(
                    width: 220,
                    child: AppButton(
                      label: 'Submit Payment',
                      onPressed: () => Get.dialog(const SubmitPaymentDialog()),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => Get.find<SessionService>().logOut(),
                  child: const Text('Log Out', style: AppTypography.bodyLg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _headline(SubscriptionService subscription) {
    if (subscription.clockTamperDetected.value) return "Check This Computer's Clock";
    if (subscription.status.value == null) return 'Verifying Subscription';
    if (subscription.status.value == SubscriptionStatus.pendingApproval) return 'Awaiting Approval';
    return 'Subscription Expired';
  }

  String _body(SubscriptionService subscription) {
    if (subscription.clockTamperDetected.value) {
      return "This computer's date and time look incorrect. Please correct them in "
          "Windows settings, then restart the app.";
    }
    if (subscription.status.value == null) {
      return "We couldn't verify this shop's subscription. Please connect to the "
          "internet and reopen the app.";
    }
    if (subscription.status.value == SubscriptionStatus.pendingApproval) {
      return "Your shop's registration is still awaiting approval. We'll let you "
          "know as soon as it's confirmed — no payment is needed yet.";
    }
    if (subscription.paymentPendingReview.value) {
      return "We've received your payment and it's waiting on review. The app "
          "will unlock automatically once it's confirmed.";
    }
    return "This shop's monthly subscription is past due and the grace period "
        "has ended. Submit a payment to keep using the app.";
  }

  bool _showsSubmitButton(SubscriptionService subscription) {
    if (subscription.clockTamperDetected.value) return false;
    if (subscription.status.value == null) return false;
    if (subscription.status.value == SubscriptionStatus.pendingApproval) return false;
    if (subscription.paymentPendingReview.value) return false;
    return true;
  }
}