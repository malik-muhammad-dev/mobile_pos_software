import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stat_card.dart';
import '../controllers/reports_controller.dart';
import '../widgets/low_stock_model_alert.dart';
import '../widgets/payment_method_breakdown.dart';
import '../widgets/report_range_switcher.dart';
import '../widgets/top_model_list.dart';

/// Owner-only dashboard — pulls the key numbers out of Sales, Inventory
/// and Customers & Ledger into one screen instead of an owner checking
/// three separate screens to know how the shop is doing.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reports', style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Sales performance, stock alerts, and Udhar — all in one place.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(
              () => ReportRangeSwitcher(
                selected: controller.selectedRange.value,
                onChanged: controller.setRange,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.payments_outlined,
                      label: 'Total Revenue',
                      value: CurrencyText(controller.totalRevenue, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_up,
                      label: 'Total Profit',
                      value: CurrencyText(controller.totalProfit, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transactions',
                      value: Text('${controller.transactionCount}', style: AppTypography.headlineLg),
                      accent: AppColors.partial,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.calculate_outlined,
                      label: 'Average Sale',
                      value: CurrencyText(controller.averageSale, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.factoryUnlockedInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Methods', style: AppTypography.headlineMd),
                          const SizedBox(height: AppSpacing.lg),
                          PaymentMethodBreakdown(totals: controller.paymentMethodBreakdown),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top Selling Models', style: AppTypography.headlineMd),
                          const SizedBox(height: AppSpacing.sm),
                          TopModelsList(models: controller.topModels),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gutter),
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         const Row(
                            children:  [
                              Icon(Icons.warning_amber_outlined, color: AppColors.warning, size: 20),
                              SizedBox(width: AppSpacing.sm),
                              Text('Low Stock Alerts', style: AppTypography.headlineMd),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LowStockAlertCard(
                            androidProducts: controller.lowStockAndroidProducts,
                            lowStockIphoneModelCount: controller.lowStockIphoneModelCount,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Outstanding Udhar', style: AppTypography.headlineMd),
                          const SizedBox(height: AppSpacing.md),
                          CurrencyText(
                            controller.outstandingUdhar,
                            style: AppTypography.displayNum,
                            isLiveValue: true,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${controller.customersWithBalanceCount} customer${controller.customersWithBalanceCount == 1 ? '' : 's'} owe money right now',
                            style: AppTypography.bodyMd,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}