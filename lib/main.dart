import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/app_root/app_root.dart';
import 'core/services/core_services_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/crash_fallback_screen.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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
      initialBinding: CoreServicesBinding(),
      home: const AppRoot(),
    );
  }
}