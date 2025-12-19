import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text }

enum ButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final String? label;
  final double? width;
  final double height;
  final AppButtonVariant variant;
  final ButtonVariant? buttonVariant;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const AppButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.label,
    this.width,
    this.height = 50,
    this.variant = AppButtonVariant.primary,
    this.buttonVariant,
    this.icon,
    this.isLoading = false,
    this.color,
  }) : assert(text != null || child != null || label != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(isDark),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : _buildChild(context, isDark),
      ),
    );
  }

  Widget _buildChild(BuildContext context, bool isDark) {
    if (child != null) return child!;

    final displayText = text ?? label ?? '';

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              displayText,
              style: _getTextStyle(isDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      displayText,
      style: _getTextStyle(isDark),
      overflow: TextOverflow.ellipsis,
    );
  }

  AppButtonVariant get _effectiveVariant {
    if (buttonVariant != null) {
      switch (buttonVariant!) {
        case ButtonVariant.primary:
          return AppButtonVariant.primary;
        case ButtonVariant.secondary:
          return AppButtonVariant.secondary;
        case ButtonVariant.outline:
          return AppButtonVariant.outline;
        case ButtonVariant.text:
          return AppButtonVariant.text;
      }
    }
    return variant;
  }

  ButtonStyle _getButtonStyle(bool isDark) {
    final bgLight = AppColors.background;
    final bgDark = const Color(0xFF2D3748);
    
    switch (_effectiveVariant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDark ? bgDark : bgLight,
          foregroundColor: color ?? AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        );

      case AppButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color ?? AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            side: BorderSide(
              color: isDark ? (color ?? AppColors.primary).withOpacity(0.7) : (color ?? AppColors.primary),
            ),
          ),
        );

      case AppButtonVariant.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color ?? AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
        );
    }
  }

  TextStyle _getTextStyle(bool isDark) {
    Color textColor;
    switch (_effectiveVariant) {
      case AppButtonVariant.primary:
        textColor = AppColors.white;
        break;
      case AppButtonVariant.secondary:
        textColor = color ?? AppColors.primary;
        break;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        textColor = color ?? AppColors.primary;
        break;
    }

    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF2D3748) : AppColors.background;
    final defaultColor = isDark ? Colors.white70 : AppColors.textSecondary;
    
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color ?? defaultColor, size: size * 0.5),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
