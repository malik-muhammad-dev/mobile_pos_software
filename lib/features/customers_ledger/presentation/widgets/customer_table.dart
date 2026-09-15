import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/customers_controller.dart';

/// One row per customer — name, phone, current balance, and a Clear/Udhar
/// badge so the shop can tell at a glance who still owes money.
class CustomersTable extends StatelessWidget {
  const CustomersTable({
    super.key,
    required this.customers,
    required this.balanceFor,
    required this.onTap,
  });

  final List<SampleCustomer> customers;
  final int Function(String customerId) balanceFor;
  final ValueChanged<SampleCustomer> onTap;

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'No customers match your search.',
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Name', flex: 3, minWidth: 150),
        AppDataColumn('Phone', flex: 2, minWidth: 130),
        AppDataColumn('Balance', flex: 2, minWidth: 120),
        AppDataColumn('Status', flex: 2, minWidth: 100),
        AppDataColumn('', flex: 1, minWidth: 36),
      ],
      rows: [
        for (final customer in customers)
          [
            InkWell(
              onTap: () => onTap(customer),
              child: Text(customer.name, style: AppTypography.bodyLg),
            ),
            Text(customer.phone, style: AppTypography.bodyMd),
            CurrencyText(balanceFor(customer.id)),
            balanceFor(customer.id) > 0
                ? const StatusBadge(label: 'Udhar', ink: AppColors.pending, bg: AppColors.warningBg, icon: Icons.schedule_outlined)
                : const StatusBadge(label: 'Clear', ink: AppColors.paid, bg: AppColors.successBg, icon: Icons.check_circle_outline),
            InkWell(
              onTap: () => onTap(customer),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: AppColors.textMuted),
              ),
            ),
          ],
      ],
    );
  }
}