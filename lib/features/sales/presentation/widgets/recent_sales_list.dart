import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
        AppDataColumn('Amount', flex: 2, minWidth: 100),
        AppDataColumn('Payment', flex: 2, minWidth: 100),
      ],
      rows: [
        for (final sale in sales)
          [
            Text(sale.time),
            Text(sale.customerName),
            CurrencyText(sale.amount),
            sale.isUdhar
                ? const StatusBadge(
                    label: 'Udhar',
                    ink: AppColors.pending,
                    bg: AppColors.warningBg,
                    icon: Icons.schedule_outlined,
                  )
                : const StatusBadge(
                    label: 'Cash',
                    ink: AppColors.paid,
                    bg: AppColors.successBg,
                    icon: Icons.check_circle_outline,
                  ),
          ],
      ],
    );
  }
}