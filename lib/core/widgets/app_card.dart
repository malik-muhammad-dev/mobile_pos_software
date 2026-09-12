import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Base container for every card-shaped surface in the app — variant list
/// rows, summary tiles, form sections. Wraps the CardTheme set on AppTheme
/// so padding stays consistent everywhere.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.gutter),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(child: Padding(padding: padding, child: child));
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}