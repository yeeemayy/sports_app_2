import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/providers/watchlist_notifier.dart';

class WatchlistBellButton extends ConsumerWidget {
  const WatchlistBellButton({super.key, required this.entry});

  final WatchlistEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(watchlistNotifierProvider.notifier);
    final isWatchlisted = ref.watch(
      watchlistNotifierProvider.select(
        (s) => s.valueOrNull?.any((e) => e.matchId == entry.matchId) ?? false,
      ),
    );

    return IconButton(
      onPressed: () {
        if (isWatchlisted) {
          notifier.remove(entry.matchId);
        } else {
          notifier.add(entry);
        }
      },
      icon: Icon(
        isWatchlisted
            ? Icons.notifications_active_rounded
            : Icons.notifications_outlined,
        color: Colors.white,
      ),
      iconSize: 22,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        side: BorderSide(
          color: isWatchlisted
              ? const Color(0xFF2ECC71).withValues(alpha: 0.6)
              : Theme.of(context).extension<AppColors>()!.lineStrong,
          width: 0.5,
        ),
        shape: const CircleBorder(),
      ),
    );
  }
}
