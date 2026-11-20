import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared_widgets/state_widgets.dart';
import 'community_header_bar.dart';
import 'community_skeletons.dart';
import 'providers/community_providers.dart';

class CommunityTrendingTopicsScreen extends ConsumerWidget {
  const CommunityTrendingTopicsScreen({super.key});

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = _locale(context);
    final async = ref.watch(communityHashtagsProvider(locale));

    return Scaffold(
      appBar: communityHeaderBar(context, title: 'community.trending_topics'.tr()),
      body: async.when(
        loading: () => const CommunityTopicRowSkeleton(),
        error: (e, st) => const ErrorStateWidget(),
        data: (hashtags) {
          if (hashtags.isEmpty) return const EmptyStateWidget(title: 'community.empty');
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: hashtags.length,
            separatorBuilder: (context, i) => Divider(height: 1, color: context.appColors.surface2),
            itemBuilder: (context, i) {
              final hashtag = hashtags[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: context.appColors.accent,
                  foregroundColor: Colors.white,
                  child: Text('#${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
                title: Text('#${hashtag.name}', style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
                trailing: Text(
                  'community.posts_count'.tr(namedArgs: {'n': '${hashtag.postsCount}'}),
                  style: AppTextStyles.body(11).copyWith(color: context.appColors.text2).copyWith(color: context.appColors.text3),
                ),
                onTap: () => context.push('/community/hashtag/${hashtag.name}'),
              );
            },
          );
        },
      ),
    );
  }
}
