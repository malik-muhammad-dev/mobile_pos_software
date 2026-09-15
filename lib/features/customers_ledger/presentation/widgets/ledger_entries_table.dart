import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/customers_controller.dart';

/// A single customer's transaction history — every charge (money they
/// were left owing) and payment (money they've paid back since), newest
/// first.
class LedgerEntriesTable extends StatelessWidget {
  const LedgerEntriesTable({super.key, required this.entries});

  final List<SampleLedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No transactions yet.',
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Date', flex: 2, minWidth: 100),
        AppDataColumn('Description', flex: 4, minWidth: 160),
        AppDataColumn('Type', flex: 2, minWidth: 110),
        AppDataColumn('Amount', flex: 2, minWidth: 110),
      ],
      rows: [
        for (final entry in entries)
          [
            Text(DateFormat('d MMM yyyy').format(entry.dateTime)),
            Text(entry.description, overflow: TextOverflow.ellipsis),
            entry.type == LedgerEntryType.charge
                ? const StatusBadge(label: 'Charge', ink: AppColors.pending, bg: AppColors.warningBg, icon: Icons.arrow_upward)
                : const StatusBadge(label: 'Payment', ink: AppColors.paid, bg: AppColors.successBg, icon: Icons.arrow_downward),
            CurrencyText(entry.amount),
          ],
      ],
    );
  }
}