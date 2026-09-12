import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The persistent split-screen layout for both Login and Setup Wizard: a
/// solid brand panel on one side, the active step's content on the other.
/// Neither panel changes when a step changes — only what's inside them
/// does — so this reads as one continuous screen, not a page hopping to
/// a new destination each step.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.brand, required this.content});

  final Widget brand;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(AppSpacing.xl),
              alignment: Alignment.centerLeft,
              child: brand,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.canvas,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}