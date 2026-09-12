import 'package:flutter/material.dart';
import 'empty_state.dart';

/// Placeholder body for every AppShell nav destination until its real
/// screen is built. Deliberately plain — this is scaffolding, not a
/// screen to review.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.construction_outlined,
      message: "$title isn't built yet.",
    );
  }
}