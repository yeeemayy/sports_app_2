import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';

/// Shared async shell used by every league tab.
///
/// Handles the loading / error / empty triangle so each tab's build method
/// only needs to describe the *happy-path* layout.
///
/// ```dart
/// return LeagueTabContent(
///   async: ref.watch(footballStandingsProvider(leagueId: leagueId)),
///   isEmpty: (groups) => groups.isEmpty,
///   builder: (groups) => SingleChildScrollView(child: ...),
/// );
/// ```
class LeagueTabContent<T> extends StatelessWidget {
  const LeagueTabContent({
    super.key,
    required this.async,
    required this.builder,
    this.isEmpty,
  });

  final AsyncValue<T> async;

  /// Called with data when loading succeeds and [isEmpty] (if provided)
  /// returns false.
  final Widget Function(T data) builder;

  /// Return true to show the empty state instead of calling [builder].
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _emptyText(context),
      data: (data) {
        if (isEmpty?.call(data) == true) return _emptyText(context);
        return builder(data);
      },
    );
  }

  Widget _emptyText(BuildContext context) => Center(
    child: Text(
      'league.empty'.tr(),
      style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
    ),
  );
}
