import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final rawScale = ResponsiveUtils.textScaleFactor(context);
    final scale = isTablet ? rawScale * 1.3 : rawScale;
    final iconSize = 20 * scale;

    Widget? prefixIconWidget;
    BoxConstraints? prefixIconConstraints;
    if (widget.prefixIcon != null) {
      if (isTablet) {
        final iconLeftPadding = 20 * rawScale;
        prefixIconWidget = Padding(
          padding: EdgeInsets.only(left: iconLeftPadding),
          child: Icon(widget.prefixIcon, color: AppColors.inputHint, size: iconSize),
        );
        prefixIconConstraints = BoxConstraints(
          minWidth: iconSize + iconLeftPadding + 12 * rawScale,
          minHeight: 0,
        );
      } else {
        prefixIconWidget = Icon(widget.prefixIcon, color: AppColors.inputHint, size: iconSize);
      }
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: AppTextStyles.inputText.copyWith(fontSize: 14 * scale),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.inputText.copyWith(fontSize: 14 * scale, color: AppColors.inputHint),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
        prefixIcon: prefixIconWidget,
        prefixIconConstraints: prefixIconConstraints,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.inputHint,
                  size: iconSize,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}
