import 'package:flutter/material.dart';
import '../services/staff_model.dart';

/// One destination in the AppShell nav. `roles` decides who sees it at
/// all — a Cashier-hidden item must be genuinely absent from the list,
/// never rendered-then-disabled. Screens themselves get supplied later;
/// for now each builds a ComingSoonScreen placeholder.
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.roles,
    required this.builder,
  });

  final String id;
  final String label;
  final IconData icon;
  final Set<StaffRole> roles;
  final WidgetBuilder builder;

  bool visibleFor(StaffRole role) => roles.contains(role);
}