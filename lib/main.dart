import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_root/app_root.dart';
import 'core/config/supabase_config.dart';
import 'core/services/core_services_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/crash_fallback_screen.dart';
import 'features/auth/presentation/bindings/auth_binding.dart';
import 'features/customers_ledger/presentation/bindings/customers_ledger_binding.dart';
import 'features/inventory/presentations/bindings/inventory_binding.dart';
import 'features/reports/presentation/bindings/reports_binding.dart';
import 'features/sales/presentation/bindings/sales_binding.dart';
import 'features/settings_shop_config/presentation/bindings/settings_binding.dart';
import 'features/shop_account/presentation/bindings/shop_account_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);

  // An unhandled widget error should never show shop staff a stack trace.
  ErrorWidget.builder = (details) => const CrashFallbackScreen();

  runApp(const MobileShopPosApp());
}

class MobileShopPosApp extends StatelessWidget {
  const MobileShopPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mobile Shop POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: BindingsBuilder(() {
        CoreServicesBinding().dependencies();
        ShopAccountBinding().dependencies();
        AuthBinding().dependencies();
        SalesBinding().dependencies();
        InventoryBinding().dependencies();
        CustomersLedgerBinding().dependencies();
        ReportsBinding().dependencies();
        SettingsBinding().dependencies();
      }),
      home: const AppRoot(),
    );
  }
}