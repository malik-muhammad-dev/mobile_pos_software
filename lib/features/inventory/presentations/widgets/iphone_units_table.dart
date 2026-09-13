import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/imei_chip.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/inventory_controller.dart';

/// One row per physical unit — IMEI and compliance only make sense at the
/// unit level, so unlike Android's table this never groups by model.
class IphoneUnitsTable extends StatelessWidget {
  const IphoneUnitsTable({super.key, required this.units});

  final List<SampleIphoneUnit> units;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const EmptyState(
        icon: Icons.phone_iphone_outlined,
        message: 'No iPhones in stock yet.',
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Model', flex: 3, minWidth: 150),
        AppDataColumn('IMEI', flex: 2, minWidth: 170),
        AppDataColumn('Compliance', flex: 3, minWidth: 160),
        AppDataColumn('Status', flex: 2, minWidth: 110),
        AppDataColumn('Price', flex: 2, minWidth: 100),
      ],
      rows: [
        for (final unit in units)
          [
            _ModelCell(unit: unit),
            ImeiChip(unit.imei),
            StatusBadge.compliance(unit.compliance),
            StatusBadge(label: unit.status.label, ink: unit.status.ink, bg: unit.status.bg, icon: unit.status.icon),
            CurrencyText(unit.price),
          ],
      ],
    );
  }
}

class _ModelCell extends StatelessWidget {
  const _ModelCell({required this.unit});

  final SampleIphoneUnit unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(unit.model, style: AppTypography.bodyLg),
        Text(
          '${unit.storage} • ${unit.color} • ${unit.condition}',
          style: AppTypography.bodySm,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}