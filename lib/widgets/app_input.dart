import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_styles.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.prefixIconData,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final hintColor = isDark ? Colors.white38 : AppColors.textHint;
    final labelColor = isDark ? Colors.white : AppColors.textPrimary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppStyles.labelLarge.copyWith(color: labelColor),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppStyles.bodyLarge.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppStyles.bodyLarge.copyWith(color: hintColor),
            filled: true,
            fillColor: bgColor,
            prefixIcon: widget.prefixIcon ?? (widget.prefixIconData != null 
                ? Icon(widget.prefixIconData, color: hintColor, size: 20) 
                : null),
            suffixIcon: widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: AppStyles.inputBorder,
            enabledBorder: AppStyles.inputBorder,
            focusedBorder: AppStyles.inputFocusedBorder,
            errorBorder: AppStyles.inputErrorBorder,
            focusedErrorBorder: AppStyles.inputErrorBorder,
            errorStyle: AppStyles.caption.copyWith(color: AppColors.error),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
        ),
      ],
    );
  }
}

class AppSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const AppSearchInput({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final hintColor = isDark ? Colors.white38 : AppColors.textHint;
    final iconColor = isDark ? Colors.white54 : AppColors.textSecondary;
    
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppStyles.bodyMedium.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: hint ?? 'Cari...',
          hintStyle: AppStyles.bodyMedium.copyWith(color: hintColor),
          prefixIcon: Icon(Icons.search, color: iconColor),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(Icons.close, size: 18, color: iconColor),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final hintColor = isDark ? Colors.white38 : AppColors.textHint;
    final labelColor = isDark ? Colors.white : AppColors.textPrimary;
    final iconColor = isDark ? Colors.white54 : AppColors.textSecondary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppStyles.labelLarge.copyWith(color: labelColor)),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF252836) : AppColors.surface,
            hint: hint != null
                ? Text(hint!, style: AppStyles.bodyLarge.copyWith(color: hintColor))
                : null,
            style: AppStyles.bodyLarge.copyWith(color: textColor),
            icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
          ),
        ),
      ],
    );
  }
}
