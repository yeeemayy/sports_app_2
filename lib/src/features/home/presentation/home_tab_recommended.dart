import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/providers/banner_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_live_events.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

class HomeTabRecommended extends ConsumerWidget {
  const HomeTabRecommended({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorsAsync = ref.watch(anchorListProvider());
    final bannerAsync = ref.watch(bannerProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          HomeSectionTitle(
            title: 'home.section.live_events'.tr(),
            subtitle: 'home.section.live_events_count'.tr(namedArgs: {'count': '14'}),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const HomeLiveEvents(),
            ),
          ),
          bannerAsync.whenOrNull(
            data: (banner) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: banner.cover,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Skeletonizer(
                    enabled: true,
                    child: const SizedBox(
                      height: 180,
                      child: ColoredBox(color: Colors.grey),
                    ),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),
          ) ?? const SizedBox.shrink(),
          HomeSectionTitle(title: 'home.section.anchor_rankings'.tr(), onPressed: () {}),
          SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) => const AnchorAvatar(),
            ),
          ),
          HomeSectionTitle(title: 'home.section.anchor_live'.tr(), onPressed: () {}),
          anchorsAsync.when(
            loading: () => HomeAnchorLiveGrid(),
            error: (err, stack) {
              print('$err\n$stack');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('home.error.load_failed'.tr()),
                ),
              );
            },
            data: (page) => HomeAnchorLiveGrid(anchors: page.data),
          ),
        ],
      ),
    );
  }
}
