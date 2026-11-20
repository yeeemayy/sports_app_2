import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/app_back_button.dart';

/// Pushed-screen header matching the app's own convention (see
/// `edit_profile_screen.dart`'s header bar): a bordered circular back
/// button and a big uppercase display-font title, instead of a plain
/// default `AppBar` these Community screens originally shipped with.
AppBar communityHeaderBar(BuildContext context, {required String title, List<Widget>? actions}) {
  final colors = context.appColors;
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleSpacing: 8,
    leadingWidth: 62,
    leading: communityHeaderBackButton(context),
    title: Text(
      title.toUpperCase(),
      style: AppTextStyles.display(20, context).copyWith(color: colors.text),
      overflow: TextOverflow.ellipsis,
    ),
    actions: actions,
  );
}

/// Just the bordered circular back button, for screens whose `AppBar.title`
/// is a widget (a search field) rather than plain text.
Widget communityHeaderBackButton(BuildContext context) {
  return const Center(child: AppBackButton());
}
