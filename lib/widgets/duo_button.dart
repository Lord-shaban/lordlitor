import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';

/// Duolingo-style 3D raised button with a thick bottom border shadow.
class DuoButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color? shadowColor;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double fontSize;
  final bool isOutlined;
  final bool isDisabled;
  final double borderRadius;
  final EdgeInsets padding;

  const DuoButton({
    super.key,
    required this.text,
    required this.color,
    this.shadowColor,
    this.onPressed,
    this.icon,
    this.fontSize = 17,
    this.isOutlined = false,
    this.isDisabled = false,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  Color get _shadow => widget.shadowColor ?? AppColors.getShadow(widget.color);

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.isDisabled || widget.onPressed == null;
    final double bottomBorder = _isPressed ? 2 : 5;
    final double topOffset = _isPressed ? 3 : 0;

    if (widget.isOutlined) {
      return _buildOutlined(disabled);
    }

    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              setState(() => _isPressed = true);
              HapticFeedback.lightImpact();
            },
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
      onTapCancel: disabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        transform: Matrix4.translationValues(0, topOffset, 0),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey[300] : widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border(
            bottom: BorderSide(
              color: disabled ? Colors.grey[400]! : _shadow,
              width: bottomBorder,
            ),
          ),
        ),
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.cairo( 
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: disabled ? Colors.grey[500] : Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(bool disabled) {
    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              setState(() => _isPressed = true);
              HapticFeedback.lightImpact();
            },
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
      onTapCancel: disabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: disabled ? Colors.grey[300]! : const Color(0xFFE5E5E5),
            width: 2.5,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.cairo( 
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: disabled ? Colors.grey : AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small circular icon button with Duolingo 3D effect.
class DuoIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final double size;

  const DuoIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
    this.size = 48,
  });

  @override
  State<DuoIconButton> createState() => _DuoIconButtonState();
}

class _DuoIconButtonState extends State<DuoIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final shadow = AppColors.getShadow(widget.color);
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = true);
              HapticFeedback.selectionClick();
            },
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border(
            bottom: BorderSide(
              color: shadow,
              width: _pressed ? 1 : 3,
            ),
          ),
        ),
        child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.45),
      ),
    );
  }
}



