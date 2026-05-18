import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

class OtpInputBoxes extends StatefulWidget {
  const OtpInputBoxes({
    required this.value,
    required this.onChanged,
    required this.enabled,
    this.onCompleted,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final VoidCallback? onCompleted;

  @override
  State<OtpInputBoxes> createState() => _OtpInputBoxesState();
}

class _OtpInputBoxesState extends State<OtpInputBoxes> {
  static const _length = LoginState.otpLength;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
    _syncFromValue(widget.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) _focusNodes.first.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant OtpInputBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncFromValue(widget.value);
    }
  }

  void _syncFromValue(String value) {
    for (var i = 0; i < _length; i++) {
      final digit = i < value.length ? value[i] : '';
      if (_controllers[i].text != digit) {
        _controllers[i].text = digit;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emitCode() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == _length) {
      widget.onCompleted?.call();
    }
  }

  void _applyPastedCode(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final code = digits.length > _length ? digits.substring(0, _length) : digits;
    for (var i = 0; i < _length; i++) {
      _controllers[i].text = i < code.length ? code[i] : '';
    }
    _emitCode();
    if (code.length == _length) {
      _focusNodes.last.unfocus();
    } else {
      _focusNodes[code.length.clamp(0, _length - 1)].requestFocus();
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _applyPastedCode(value);
      return;
    }

    final digit = value.replaceAll(RegExp(r'\D'), '');
    _controllers[index].text = digit;

    if (digit.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _emitCode();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Six digit verification code',
      textField: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_length, (index) {
          final filled = _controllers[index].text.isNotEmpty;
          final focused = _focusNodes[index].hasFocus;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: focused
                        ? AppColors.primary
                        : filled
                        ? AppColors.secondary.withValues(alpha: 0.55)
                        : const Color(0xFFD6DFEA),
                    width: focused ? 2 : 1.2,
                  ),
                  boxShadow: focused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                  onChanged: (v) => _onDigitChanged(index, v),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
