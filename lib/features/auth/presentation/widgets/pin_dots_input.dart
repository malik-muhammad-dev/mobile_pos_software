import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A single PIN field, shown as dots via Flutter's own obscureText — no
/// custom on-screen keypad. This is a desktop app with a real keyboard, so
/// staff just type their PIN like any other password field.
class PinDotsInput extends StatefulWidget {
  const PinDotsInput({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.length = 4,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onCompleted;
  final int length;
  final bool autofocus;

  @override
  State<PinDotsInput> createState() => _PinDotsInputState();
}

class _PinDotsInputState extends State<PinDotsInput> {
  int _lastLength = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  void _handleChange() {
    final currentLength = widget.controller.text.length;
    if (currentLength == widget.length && _lastLength != widget.length) {
      widget.onCompleted(widget.controller.text);
    }
    _lastLength = currentLength;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: widget.controller,
        autofocus: widget.autofocus,
        obscureText: true,
        obscuringCharacter: '●',
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: widget.length,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.headlineLg.copyWith(
          color: AppColors.primary,
          letterSpacing: 18,
        ),
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}