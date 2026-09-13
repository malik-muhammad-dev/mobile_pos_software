import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../controllers/sales_controller.dart';
import '../widgets/recent_sales_list.dart';
import '../../../../core/widgets/stat_card.dart';

/// Sales doubles as the dashboard — there is no separate Dashboard nav
/// item by design. First thing anyone sees after logging in, so it leads
/// with the numbers that matter at a glance (today's sales, outstanding
/// udhar) before anything else.
class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesController());
    final staff = Get.find<SessionService>().currentStaff.value;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}${staff != null ? ', ${staff.name}' : ''}',
                        style: AppTypography.headlineLg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text("Here's how the shop is doing today.", style: AppTypography.bodyMd),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.gutter),
                SizedBox(
                  width: 180,
                  child: AppButton(
                    label: 'New Sale',
                    icon: Icons.add,
                    onPressed: controller.onNewSaleTapped,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.point_of_sale_outlined,
                      label: "Today's Sales",
                      value: CurrencyText(controller.todaysSalesTotal.value, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.schedule_outlined,
                      label: 'Udhar Outstanding',
                      value: CurrencyText(controller.udharOutstanding.value, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transactions Today',
                      value: Text('${controller.transactionsToday.value}', style: AppTypography.headlineLg),
                      accent: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text("Today's Activity", style: AppTypography.headlineMd),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              // .toList() forces Obx to actually read the RxList here (inside
              // its own builder) rather than leaving the read to happen later
              // inside RecentSalesList.build(), which is outside the window
              // GetX tracks — that gap is what threw "improper use of GetX".
              child: Obx(() => RecentSalesList(sales: controller.recentSales.toList())),
            ),
          ],
        ),
      ),
    );
  }
}