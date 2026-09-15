import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stat_card.dart';
import '../controllers/customers_controller.dart';
import '../widgets/customer_table.dart';
import 'customer_detail_screen.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomersController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customers & Ledger', style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Track who owes what (Udhar) and record payments as they come in.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Total Outstanding',
                      value: CurrencyText(controller.totalOutstanding, style: AppTypography.headlineLg, isLiveValue: true),
                      accent: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.schedule_outlined,
                      label: 'Customers With Balance',
                      value: Text('${controller.customersWithBalanceCount}', style: AppTypography.headlineLg),
                      accent: AppColors.pending,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.people_outline,
                      label: 'Total Customers',
                      value: Text('${controller.customers.length}', style: AppTypography.headlineLg),
                      accent: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Search',
              hint: 'Name or phone number',
              onChanged: controller.setSearchQuery,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              // filteredCustomers/balanceFor are read directly inside this
              // Obx closure (not deferred to CustomersTable's own build) —
              // same fix as Sales' RecentSalesList, so the RxList read
              // actually happens where GetX is tracking it.
              child: Obx(
                () => CustomersTable(
                  customers: controller.filteredCustomers,
                  balanceFor: controller.balanceFor,
                  onTap: (customer) => Get.to(() => CustomerDetailScreen(customerId: customer.id)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}