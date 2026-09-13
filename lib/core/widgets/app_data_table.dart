import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppDataColumn {
  const AppDataColumn(this.label, {this.flex = 1, this.minWidth = 96});

  final String label;
  final int flex;

  /// The narrowest this column is allowed to get. Below the combined
  /// minWidth of every column, the whole table switches to horizontal
  /// scrolling instead of continuing to squeeze cells — that squeeze is
  /// what caused "RenderFlex overflowed" on a shrunk window. Tune this per
  /// column to roughly its widest realistic content (an IMEI chip or a long
  /// compliance badge needs more room than a short price).
  final double minWidth;
}

/// A plain, consistently-styled row/column table — used wherever a screen
/// needs to scan many rows at once (unit lists, ledger history). Deliberately
/// simple: strong row separation, no dense borders everywhere.
///
/// Responsive by design: while the available width comfortably fits every
/// column's minWidth, columns share space by their flex ratio exactly like
/// before. Once the window is narrowed past that point, the table stops
/// shrinking columns further and becomes horizontally scrollable at its
/// minimum width instead — so a small window gets a scrollbar, never an
/// overflow error or unreadable, crushed content.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<AppDataColumn> columns;
  final List<List<Widget>> rows;

  double get _minTableWidth => columns.fold<double>(0, (sum, c) => sum + c.minWidth);

  @override
  Widget build(BuildContext context) {
    final table = _buildTable();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _minTableWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _minTableWidth, child: table),
        );
      },
    );
  }

  Widget _buildTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final column in columns)
                Expanded(
                  flex: column.flex,
                  child: Text(column.label.toUpperCase(), style: AppTypography.labelSm),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        for (final row in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++)
                  Expanded(
                    flex: i < columns.length ? columns[i].flex : 1,
                    child: row[i],
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
      ],
    );
  }
}