import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final Color? helperTextColor;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;
  final double labelFontSize;
  final Color? labelColor;
  final EdgeInsetsGeometry contentPadding;
  final BorderRadius borderRadius;
  final TextStyle textStyle;
  final Color? backgroundColor;
  final Widget? secondaryLabel;
  const CustomTextField({
    super.key,
    required this.textEditingController,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.helperTextColor,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.labelFontSize = 13,
    this.labelColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.contentPadding = const EdgeInsets.all(16),
    this.textStyle = const TextStyle(fontSize: 12),
    this.backgroundColor,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLabelColor = labelColor ?? context.appColors.text2;
    final resolvedBgColor = backgroundColor ?? context.appColors.surface2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (label != null) ...[
          //   Row(
          //     children: [
          //       Text(
          //         label!,
          //         style: TextStyle(
          //           fontSize: labelFontSize,
          //           color: labelColor,
          //           fontWeight: FontWeight.w700,
          //           fontVariations: [
          //             FontVariation('wght', 700),
          //             FontVariation('opsz', labelFontSize),
          //           ],
          //         ),
          //       ),
          //       if (secondaryLabel != null) ...[
          //         Expanded(
          //           child: Padding(
          //             padding: const EdgeInsets.only(left: 4.0),
          //             child: secondaryLabel!,
          //           ),
          //         ),
          //       ],
          //     ],
          //   ),
          //   const SizedBox(height: 8),
          // ],
          TextFormField(
            controller: textEditingController,
            obscureText: obscureText,
            textAlign: TextAlign.left,
            style: textStyle.copyWith(color: resolvedLabelColor),
            maxLines: maxLines,
            cursorColor: context.appColors.accent,
            keyboardType: keyboardType,
            readOnly: readOnly,
            enabled: enabled,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            validator: validator,
            focusNode: focusNode,
            onTap: onTap,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              errorText: errorText,
              hintText: hintText ?? label,
              hintStyle: textStyle.copyWith(color: Colors.grey),
              prefixIcon: prefixIcon != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: prefixIcon,
                        ),
                      ],
                    )
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: enabled
                  ? resolvedBgColor
                  : context.appColors.accent.withValues(alpha: 0.2),
              helperText: helperText,
              helperMaxLines: 6,
              helperStyle: TextStyle(
                fontSize: 11,
                color: helperTextColor ?? const Color(0xff707070),
              ),
              errorMaxLines: 2,
              contentPadding: contentPadding,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: borderRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.appColors.accent),
                borderRadius: borderRadius,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: borderRadius,
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: borderRadius,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.colorScheme.error),
                borderRadius: borderRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
