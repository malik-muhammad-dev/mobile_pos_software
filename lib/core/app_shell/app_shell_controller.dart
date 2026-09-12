import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/session_service.dart';
import '../services/staff_model.dart';
import '../widgets/coming_soon_screen.dart';
import 'nav_item.dart';

/// Defines the 5-module nav (Sales, Inventory, Customers & Ledger, Reports,
/// Settings) and which role sees which entries. Purchases & Vendors and a
/// dedicated Staff Accounts screen are intentionally not here — cut from
/// this build's scope.
class AppShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<NavItem> _allItems = [
    NavItem(
      id: 'sales',
      label: 'Sales',
      icon: Icons.point_of_sale_outlined,
      roles: {StaffRole.owner, StaffRole.cashier},
      builder: (_) => const ComingSoonScreen(title: 'Sales'),
    ),
    NavItem(
      id: 'inventory',
      label: 'Inventory',
      icon: Icons.inventory_2_outlined,
      roles: {StaffRole.owner},
      builder: (_) => const ComingSoonScreen(title: 'Inventory'),
    ),
    NavItem(
      id: 'stock_lookup',
      label: 'Stock Lookup',
      icon: Icons.search_outlined,
      roles: {StaffRole.cashier},
      builder: (_) => const ComingSoonScreen(title: 'Stock Lookup'),
    ),
    NavItem(
      id: 'customers_ledger',
      label: 'Customers & Ledger',
      icon: Icons.menu_book_outlined,
      roles: {StaffRole.owner, StaffRole.cashier},
      builder: (_) => const ComingSoonScreen(title: 'Customers & Ledger'),
    ),
    NavItem(
      id: 'reports',
      label: 'Reports',
      icon: Icons.insights_outlined,
      roles: {StaffRole.owner},
      builder: (_) => const ComingSoonScreen(title: 'Reports'),
    ),
    NavItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      roles: {StaffRole.owner},
      builder: (_) => const ComingSoonScreen(title: 'Settings'),
    ),
  ];

  List<NavItem> itemsFor(StaffRole role) =>
      _allItems.where((item) => item.visibleFor(role)).toList();

  void select(int index) => selectedIndex.value = index;

  void logOut() {
    selectedIndex.value = 0;
    Get.find<SessionService>().logOut();
  }
}