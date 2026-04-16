import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/providers/banner_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';
import 'package:sports_app/src/features/video/presentation/widgets/home_video_list.dart';

class HomeTabOthers extends ConsumerWidget {
  const HomeTabOthers({super.key});

  String _locale(BuildContext context) =>
      context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorsAsync = ref.watch(anchorListProvider());
    final bannerAsync = ref.watch(bannerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(anchorListProvider().future);
        ref.refresh(bannerProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: Column(
          children: [
            bannerAsync.whenOrNull(
                  data: (banner) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: banner.cover,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: const SizedBox(height: 180, child: ColoredBox(color: Colors.grey)),
                        ),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),
            anchorsAsync.when(
              loading: () => Column(
                children: [
                  HomeSectionTitle(
                    icon: 'assets/images/live-tv.png',
                    title: 'home.section.anchor_live'.tr(),
                    onPressed: () {},
                  ),
                  const HomeAnchorLiveGrid(),
                ],
              ),
              error: (err, stack) => Column(
                children: [
                  HomeSectionTitle(
                    icon: 'assets/images/news.png',
                    title: 'home.section.video_highlights'.tr(),
                    onPressed: () {},
                  ),
                  HomeVideoList(locale: _locale(context)),
                ],
              ),
              data: (page) => Column(
                children: [
                  HomeSectionTitle(
                    icon: 'assets/images/live-tv.png',
                    title: 'home.section.anchor_live'.tr(),
                    onPressed: () {},
                  ),
                  HomeAnchorLiveGrid(anchors: page.data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
