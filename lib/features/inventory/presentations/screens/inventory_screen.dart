import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stat_card.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/android_products_table.dart';
import '../widgets/inventory_tab_switcher.dart';
import '../widgets/iphone_units_table.dart';

/// Inventory owns two very differently-shaped stock models under one roof:
/// iPhones tracked unit-by-unit (IMEI, PTA/compliance status, battery
/// health) and Android phones tracked as a quantity per model. The tab
/// switcher keeps that split without making it feel like two screens.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inventory', style: AppTypography.headlineLg),
                      SizedBox(height: AppSpacing.xs),
                      Text('Track iPhone and Android stock across your shop.', style: AppTypography.bodyMd),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.gutter),
                SizedBox(
                  width: 180,
                  child: AppButton(
                    label: 'Add Stock',
                    icon: Icons.add,
                    onPressed: controller.onAddStockTapped,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(
              () => InventoryTabSwitcher(
                selected: controller.selectedTab.value,
                onChanged: controller.selectTab,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(() {
              final isIphone = controller.selectedTab.value == InventoryTab.iphone;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.inventory_2_outlined,
                      label: isIphone ? 'iPhone Units in Stock' : 'Android Units in Stock',
                      value: Text(
                        '${isIphone ? controller.iphoneUnitsInStockCount : controller.androidUnitsInStockCount}',
                        style: AppTypography.headlineLg,
                      ),
                      accent: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.warning_amber_outlined,
                      label: 'Low Stock Models',
                      value: Text(
                        '${isIphone ? controller.iphoneLowStockModelCount : controller.androidLowStockModelCount}',
                        style: AppTypography.headlineLg,
                      ),
                      accent: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: StatCard(
                      icon: Icons.payments_outlined,
                      label: 'Total Stock Value',
                      value: CurrencyText(
                        isIphone ? controller.iphoneStockValue : controller.androidStockValue,
                        style: AppTypography.headlineLg,
                        isLiveValue: true,
                      ),
                      accent: AppColors.success,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Text(
                controller.selectedTab.value == InventoryTab.iphone ? 'iPhone Stock' : 'Android Stock',
                style: AppTypography.headlineMd,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Obx(() {
                if (controller.selectedTab.value == InventoryTab.iphone) {
                  return IphoneUnitsTable(units: controller.iphoneUnits.toList());
                }
                return AndroidProductsTable(
                  products: controller.androidProducts.toList(),
                  isLowStock: controller.isAndroidLowStock,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}