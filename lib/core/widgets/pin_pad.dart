import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Big touch-friendly numeric keypad used by both the first-run Setup
/// Wizard (choosing a PIN) and the login screen (entering it). Shows the
/// entered length as dots rather than digits — a PIN should never be
/// visible on screen.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.length,
    required this.maxLength,
    required this.onDigit,
    required this.onBackspace,
  });

  final int length;
  final int maxLength;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (i) {
            final filled = i < length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : AppColors.borderDefault,
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        _keypadGrid(),
      ],
    );
  }

  Widget _keypadGrid() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return SizedBox(
      width: 3 * 76,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.3,
        children: keys.map((key) {
          if (key.isEmpty) return const SizedBox.shrink();
          return _PinPadKey(
            label: key,
            onTap: key == '⌫' ? onBackspace : () => onDigit(key),
          );
        }).toList(),
      ),
    );
  }
}

class _PinPadKey extends StatelessWidget {
  const _PinPadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Center(child: Text(label, style: AppTypography.headlineLg)),
      ),
    );
  }
}