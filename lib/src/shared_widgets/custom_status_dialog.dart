import 'package:flutter/material.dart';

enum DialogType { success, fail, custom }

Future<void> showCustomStatusDialog({
  required BuildContext context,
  required String title,
  String? description,
  Widget? overrideContent,
  IconData? overrideIcon,
  Color? overrideIconBackgroundColor,
  required String buttonText,
  required VoidCallback onButtonPressed,
  Color? buttonBackgroundColor,
  required DialogType dialogType,
  Widget? secondaryButton,
  bool onCloseSameWithPrimaryButton = false,
  bool showCloseButton = true,
}) {
  IconData icon;
  Color iconBackgroundColor;

  switch (dialogType) {
    case DialogType.success:
      icon = overrideIcon ?? Icons.check_rounded;
      iconBackgroundColor = overrideIconBackgroundColor ?? Colors.green;
    case DialogType.fail:
      icon = overrideIcon ?? Icons.close_rounded;
      iconBackgroundColor = overrideIconBackgroundColor ?? Colors.red;
    case DialogType.custom:
      icon = overrideIcon ?? Icons.warning_amber_rounded;
      iconBackgroundColor = overrideIconBackgroundColor ?? Colors.orange;
  }

  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCloseButton)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: onCloseSameWithPrimaryButton
                        ? onButtonPressed
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24, color: Color(0xFF9E9E9E)),
                  ),
                ),

              const SizedBox(height: 16),

              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              if (title.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (description != null || overrideContent != null)
                overrideContent ??
                    Text(
                      description ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF757575)),
                    ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBackgroundColor ?? Colors.pink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onButtonPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (secondaryButton != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: secondaryButton,
                ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}
