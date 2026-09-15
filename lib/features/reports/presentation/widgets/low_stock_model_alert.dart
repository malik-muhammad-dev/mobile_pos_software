import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../inventory/presentations/controllers/inventory_controller.dart';

/// Lists Android models running low (per-product quantity below the shop's
/// threshold) plus a count of iPhone models with few units left. iPhone
/// units are tracked individually (no quantity field), so they only get a
/// model count here, not a per-unit list — the Inventory screen is still
/// the place to see exactly which units those are.
class LowStockAlertCard extends StatelessWidget {
  const LowStockAlertCard({
    super.key,
    required this.androidProducts,
    required this.lowStockIphoneModelCount,
  });

  final List<SampleAndroidProduct> androidProducts;
  final int lowStockIphoneModelCount;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = androidProducts.isNotEmpty || lowStockIphoneModelCount > 0;

    if (!hasAlerts) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Text('Stock levels look healthy — nothing running low.', style: AppTypography.bodyMd)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lowStockIphoneModelCount > 0) ...[
          _alertRow(
            icon: Icons.phone_iphone_outlined,
            text: '$lowStockIphoneModelCount iPhone model${lowStockIphoneModelCount == 1 ? '' : 's'} running low',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (final product in androidProducts) ...[
          _alertRow(
            icon: Icons.android_outlined,
            text: '${product.brand} ${product.model} — only ${product.quantity} left',
          ),
          if (product != androidProducts.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _alertRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.warning, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTypography.bodyMd)),
      ],
    );
  }
}