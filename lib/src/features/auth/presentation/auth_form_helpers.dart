import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

InputDecoration authInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.mono(13).copyWith(
      color: scheme.onSurface.withValues(alpha: 0.36),
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: scheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
      borderRadius: BorderRadius.circular(14),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: scheme.primary, width: 1),
      borderRadius: BorderRadius.circular(14),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: scheme.error, width: 0.5),
      borderRadius: BorderRadius.circular(14),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: scheme.error),
      borderRadius: BorderRadius.circular(14),
    ),
  );
}

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.mono(10).copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.36),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: isLoading ? scheme.primary.withValues(alpha: 0.6) : scheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.display(18, context).copyWith(
                      color: scheme.onPrimary,
                      height: 1,
                    ),
                  ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: scheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
