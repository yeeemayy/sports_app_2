import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/exceptions/app_exception.dart';
import 'package:sports_app/src/core/services/api_client.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';

extension ContextTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension ContextDialogs on BuildContext {
  void showErrorDialog({required String title, required Object error}) {
    final String description;
    if (error is ApiClientException) {
      description = error.displayMessage;
    } else if (error is AppException) {
      description = error.message;
    } else {
      description = 'common.error.unexpected'.tr();
    }

    showCustomStatusDialog(
      context: this,
      title: title,
      description: description,
      buttonText: 'common.ok'.tr(),
      onButtonPressed: () => Navigator.of(this).pop(),
      dialogType: DialogType.fail,
    );
  }
}