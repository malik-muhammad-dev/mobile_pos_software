import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/sales_controller.dart';

/// "Today's Activity" table — Cash sales read as settled (green, paid),
/// Udhar sales read as outstanding (amber, pending), so staff can tell at
/// a glance which transactions still need collecting.
class RecentSalesList extends StatelessWidget {
  const RecentSalesList({super.key, required this.sales});

  final List<SampleSaleEntry> sales;

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No sales yet today.',
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Time', flex: 2, minWidth: 80),
        AppDataColumn('Customer', flex: 3, minWidth: 130),
        AppDataColumn('Item', flex: 3, minWidth: 140),
        AppDataColumn('Amount', flex: 2, minWidth: 100),
        AppDataColumn('Payment', flex: 2, minWidth: 110),
      ],
      rows: [
        for (final sale in sales)
          [
            Text(sale.time),
            Text(sale.customerName),
            Text(sale.itemDescription, style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis),
            _AmountCell(sale: sale),
            sale.isUdhar
                ? const StatusBadge(
                    label: 'Udhar',
                    ink: AppColors.pending,
                    bg: AppColors.warningBg,
                    icon: Icons.schedule_outlined,
                  )
                : const StatusBadge(
                    label: 'Paid',
                    ink: AppColors.paid,
                    bg: AppColors.successBg,
                    icon: Icons.check_circle_outline,
                  ),
          ],
      ],
    );
  }
}

/// Shows the net (after-discount) amount as the primary figure; when a
/// discount was applied, the original listed price shows underneath with a
/// strikethrough so staff can see at a glance that this sale was discounted.
class _AmountCell extends StatelessWidget {
  const _AmountCell({required this.sale});

  final SampleSaleEntry sale;

  @override
  Widget build(BuildContext context) {
    if (!sale.hasDiscount) {
      return CurrencyText(sale.netPrice);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CurrencyText(sale.netPrice),
        Text(
          'Rs. ${NumberFormat.decimalPattern('en_PK').format(sale.price)}',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
}