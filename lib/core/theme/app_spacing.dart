/// Spacing and shape tokens ported from the Stitch design system.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 32;
  static const double gutter = 16;
  static const double gutterLg = 24;

  /// Minimum touch target height — big, forgiving hit areas for counter
  /// staff moving fast, sometimes on a touchscreen. Never go smaller.
  static const double touchTargetMin = 48;
  static const double touchTargetLg = 56;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4;
  static const double defaultRadius = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 999;
}