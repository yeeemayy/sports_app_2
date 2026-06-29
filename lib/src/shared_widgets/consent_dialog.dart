import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/routes/app_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';

const _kConsentKey = 'consent_accepted';

Future<void> showConsentDialogIfNeeded(BuildContext context, SharedPreferences prefs) async {
  if (Platform.isIOS || prefs.getBool(_kConsentKey) == true) return;

  await showCustomStatusDialog(
    context: context,
    dialogType: DialogType.custom,
    overrideIcon: Icons.policy_outlined,
    overrideIconBackgroundColor: context.appColors.accent,
    title: 'consent.title'.tr(),
    overrideContent: _ConsentContent(),
    buttonText: 'consent.agree'.tr(),
    onButtonPressed: () {
      prefs.setBool(_kConsentKey, true);
      Navigator.of(context).pop();
    },
    secondaryButton: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          showCustomStatusDialog(
            context: context,
            dialogType: DialogType.custom,
            overrideIcon: Icons.warning_amber_rounded,
            overrideIconBackgroundColor: context.appColors.accent,
            title: 'consent.exit_warning_title'.tr(),
            description: 'consent.exit_warning_body'.tr(),
            buttonText: 'consent.go_back'.tr(),
            onButtonPressed: () => Navigator.of(context).pop(),
            secondaryButton: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => exit(0),
                child: Text('consent.confirm_exit'.tr()),
              ),
            ),
          );
        },
        child: Text('consent.disagree'.tr()),
      ),
    ),
    showCloseButton: false,
  );
}

class _ConsentContent extends StatefulWidget {
  const _ConsentContent();

  @override
  State<_ConsentContent> createState() => _ConsentContentState();
}

class _ConsentContentState extends State<_ConsentContent> {
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _agreementRecognizer;

  @override
  void initState() {
    super.initState();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        rootNavigatorKey.currentContext?.push(
          AppRoutes.privacyPolicy,
          extra: 'profile.privacy_policy'.tr(),
        );
      };
    _agreementRecognizer = TapGestureRecognizer()
      ..onTap = () {
        rootNavigatorKey.currentContext?.push(
          AppRoutes.userAgreement,
          extra: 'profile.terms_of_use'.tr(),
        );
      };
  }

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    _agreementRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.appColors.accent;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Color(0xFF757575), height: 1.6),
        children: [
          TextSpan(text: 'consent.body_prefix'.tr()),
          TextSpan(
            text: 'consent.privacy_policy_link'.tr(),
            style: TextStyle(
              color: accentColor,
              decoration: TextDecoration.underline,
              decorationColor: accentColor,
            ),
            recognizer: _privacyRecognizer,
          ),
          TextSpan(text: 'consent.conjunction'.tr()),
          TextSpan(
            text: 'consent.user_agreement_link'.tr(),
            style: TextStyle(
              color: accentColor,
              decoration: TextDecoration.underline,
              decorationColor: accentColor,
            ),
            recognizer: _agreementRecognizer,
          ),
          TextSpan(text: 'consent.body_suffix'.tr()),
        ],
      ),
    );
  }
}
