import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/imei_chip.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/inventory_controller.dart';

/// One row per physical unit — IMEI and compliance only make sense at the
/// unit level, so unlike Android's table this never groups by model. Two
/// iPhones with the exact same model/storage/color still get two separate
/// rows (each has its own IMEI) — a small "×2" badge on the model name is
/// how the table shows "there are two of these", the same thing Android's
/// quantity column shows in a single row.
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

    // Count in-stock units sharing the same model+storage+color so the
    // model cell can show "×2" etc. — computed once per build from what's
    // already on screen, no extra controller lookup needed.
    final inStockCounts = <String, int>{};
    for (final unit in units.where((u) => u.status == UnitStockStatus.inStock)) {
      final key = '${unit.model}|${unit.storage}|${unit.color}';
      inStockCounts[key] = (inStockCounts[key] ?? 0) + 1;
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Model', flex: 3, minWidth: 160),
        AppDataColumn('IMEI', flex: 2, minWidth: 170),
        AppDataColumn('Compliance', flex: 3, minWidth: 160),
        AppDataColumn('Status', flex: 2, minWidth: 110),
        AppDataColumn('Price', flex: 2, minWidth: 120),
      ],
      rows: [
        for (final unit in units)
          [
            _ModelCell(
              unit: unit,
              sameSpecCount: unit.status == UnitStockStatus.inStock
                  ? inStockCounts['${unit.model}|${unit.storage}|${unit.color}'] ?? 1
                  : 1,
            ),
            ImeiChip(unit.imei),
            StatusBadge.compliance(unit.compliance),
            StatusBadge(label: unit.status.label, ink: unit.status.ink, bg: unit.status.bg, icon: unit.status.icon),
            _PriceCell(unit: unit),
          ],
      ],
    );
  }
}

class _ModelCell extends StatelessWidget {
  const _ModelCell({required this.unit, required this.sameSpecCount});

  final SampleIphoneUnit unit;
  final int sameSpecCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(unit.model, style: AppTypography.bodyLg, overflow: TextOverflow.ellipsis)),
            if (sameSpecCount > 1) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '×$sameSpecCount',
                  style: AppTypography.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        Text(
          '${unit.storage} • ${unit.color} • ${unit.condition}',
          style: AppTypography.bodySm,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Sale price is the primary figure (what's charged to the customer); cost
/// price shows underneath in muted text — staff can see the margin at a
/// glance without it being mistaken for the customer-facing price.
class _PriceCell extends StatelessWidget {
  const _PriceCell({required this.unit});

  final SampleIphoneUnit unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CurrencyText(unit.salePrice, style: AppTypography.bodyLg.merge(AppTypography.numeric).copyWith(fontWeight: FontWeight.w700)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cost ', style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
            CurrencyText(unit.costPrice, style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}