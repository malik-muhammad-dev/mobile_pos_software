import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/currency_text.dart';

/// One payment method's revenue share as a labeled proportional bar — no
/// charting package pulled in for one visualization; a Container sized by
/// FractionallySizedBox reads just as clearly at this scale.
class PaymentMethodBreakdown extends StatelessWidget {
  const PaymentMethodBreakdown({super.key, required this.totals});

  /// Method label -> revenue, in the display order it should render.
  final Map<String, int> totals;

  @override
  Widget build(BuildContext context) {
    final maxValue = totals.values.fold<int>(0, (max, v) => v > max ? v : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in totals.entries) ...[
          _row(entry.key, entry.value, maxValue),
          if (entry.key != totals.keys.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _row(String label, int value, int maxValue) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMd),
            CurrencyText(value, style: AppTypography.bodyLg, isLiveValue: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: 8,
            color: AppColors.canvas,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}