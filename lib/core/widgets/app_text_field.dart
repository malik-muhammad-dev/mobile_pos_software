import 'package:flutter/material.dart';

/// Standard text input — big touch target height via the InputDecorationTheme
/// set on AppTheme, so individual screens don't need to remember padding.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  /// False renders a real, disabled TextField (Flutter's own greyed-out
  /// style) instead of a normal editable one — used for a value that's
  /// fixed for now (e.g. Settings' Currency field). Deliberately a real
  /// TextField rather than a hand-built look-alike Container, so it lines
  /// up exactly with every editable field beside it instead of drifting
  /// out of alignment (different label/content padding, different total
  /// height) the way a separately-built substitute would.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autofocus: autofocus,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}