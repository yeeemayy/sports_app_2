import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.centerTitle = true,
    this.bottom,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: centerTitle,
      title: title,
      actions: actions,
      leading:
          leading ??
          (showBack && context.canPop() ? const Center(child: AppBackButton()) : null),
      bottom: bottom,
    );
  }
}
