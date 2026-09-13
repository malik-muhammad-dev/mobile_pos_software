import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/inventory_controller.dart';

/// One row per model — Android stock is tracked as a quantity per product,
/// not per physical unit, so there's no IMEI/compliance column here.
class AndroidProductsTable extends StatelessWidget {
  const AndroidProductsTable({super.key, required this.products, required this.isLowStock});

  final List<SampleAndroidProduct> products;
  final bool Function(SampleAndroidProduct) isLowStock;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.android_outlined,
        message: 'No Android phones in stock yet.',
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Model', flex: 3, minWidth: 130),
        AppDataColumn('Variant', flex: 3, minWidth: 150),
        AppDataColumn('Condition', flex: 2, minWidth: 90),
        AppDataColumn('Quantity', flex: 2, minWidth: 110),
        AppDataColumn('Price', flex: 2, minWidth: 120),
      ],
      rows: [
        for (final product in products)
          [
            Text('${product.brand} ${product.model}', style: AppTypography.bodyLg),
            Text('${product.storage} • ${product.ram} • ${product.color}', style: AppTypography.bodySm),
            Text(product.condition, style: AppTypography.bodyMd),
            _QuantityCell(quantity: product.quantity, isLow: isLowStock(product)),
            _PriceCell(product: product),
          ],
      ],
    );
  }
}

class _QuantityCell extends StatelessWidget {
  const _QuantityCell({required this.quantity, required this.isLow});

  final int quantity;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    final color = isLow ? AppColors.warning : AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLow) ...[
          Icon(Icons.warning_amber_rounded, size: 16, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            '$quantity in stock',
            style: AppTypography.bodyLg.merge(AppTypography.numeric).copyWith(color: color, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// Sale price is the primary figure (what's charged to the customer); cost
/// price shows underneath in muted text — same treatment as the iPhone
/// table, so margin is visible at a glance on both tabs.
class _PriceCell extends StatelessWidget {
  const _PriceCell({required this.product});

  final SampleAndroidProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CurrencyText(product.salePrice, style: AppTypography.bodyLg.merge(AppTypography.numeric).copyWith(fontWeight: FontWeight.w700)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cost ', style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
            CurrencyText(product.costPrice, style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}