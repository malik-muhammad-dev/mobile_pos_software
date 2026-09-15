import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../controllers/customers_controller.dart';
import '../widgets/ledger_entries_table.dart';
import '../widgets/record_payment_dailog.dart';

/// Pushed on top of AppShell (a standard list → detail drill-down), not a
/// nav-swapped tab — AppShell's sidebar only holds the top-level modules.
class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomersController>();

    return Obx(() {
      final customer = controller.customerById(customerId);
      if (customer == null) {
        // Shouldn't happen in normal use — guards against a stale id.
        return Scaffold(
          appBar: AppBar(title: const Text('Customer')),
          body: const Center(child: Text('Customer not found.')),
        );
      }

      final balance = controller.balanceFor(customerId);
      final entries = controller.entriesFor(customerId);

      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: Text(customer.name),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name, style: AppTypography.headlineMd),
                          const SizedBox(height: AppSpacing.xs),
                          Text(customer.phone, style: AppTypography.bodyMd),
                          if (customer.cnic != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'CNIC: ${customer.cnic}',
                              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(balance > 0 ? 'Balance Owed' : 'Balance', style: AppTypography.bodyMd),
                        const SizedBox(height: AppSpacing.xs),
                        CurrencyText(
                          balance,
                          style: AppTypography.headlineLg.copyWith(
                            color: balance > 0 ? AppColors.warning : AppColors.success,
                          ),
                          isLiveValue: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 220,
                child: AppButton(
                  label: 'Record Payment',
                  icon: Icons.payments_outlined,
                  onPressed: balance <= 0
                      ? null
                      : () => Get.dialog(RecordPaymentDialog(customer: customer, currentBalance: balance)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Transaction History', style: AppTypography.headlineMd),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: EdgeInsets.zero,
                child: LedgerEntriesTable(entries: entries),
              ),
            ],
          ),
        ),
      );
    });
  }
}