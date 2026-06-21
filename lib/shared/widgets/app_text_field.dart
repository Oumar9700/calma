import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/extensions/build_context_ext.dart';


class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  const AppTextField.password({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  })  : keyboardType = TextInputType.visiblePassword,
        obscureText = true,
        readOnly = false,
        maxLines = 1,
        maxLength = null,
        prefixIcon = null,
        suffixIcon = null,
        onTap = null;

  const AppTextField.multiline({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.maxLines = 4,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  })  : keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        readOnly = false,
        prefixIcon = null,
        suffixIcon = null,
        onTap = null,
        onSubmitted = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: context.colorOnSurfaceVariant,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText ? _obscureText : false,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: context.colorOnSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20.w,
                      color: context.colorOnSurfaceVariant,
                    ),
                  )
                : widget.suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
