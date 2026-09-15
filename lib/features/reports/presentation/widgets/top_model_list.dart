import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/currency_text.dart';
import '../controllers/reports_controller.dart';

/// Ranked list of what sold best in the selected range, by revenue.
class TopModelsList extends StatelessWidget {
  const TopModelsList({super.key, required this.models});

  final List<TopModelStat> models;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text('No sales in this range yet.', style: AppTypography.bodyMd),
      );
    }

    return AppDataTable(
      columns: const [
        AppDataColumn('Model', flex: 3, minWidth: 140),
        AppDataColumn('Units', flex: 1, minWidth: 64),
        AppDataColumn('Revenue', flex: 2, minWidth: 110),
      ],
      rows: [
        for (var i = 0; i < models.length; i++)
          [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text('${i + 1}', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(models[i].name, style: AppTypography.bodyLg, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Text('×${models[i].unitsSold}', style: AppTypography.bodyMd),
            CurrencyText(models[i].revenue, style: AppTypography.bodyLg, isLiveValue: true),
          ],
      ],
    );
  }
}