import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/providers/banner_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/features/video/presentation/widgets/home_video_list.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class HomeTabOthers extends ConsumerWidget {
  const HomeTabOthers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorsAsync = ref.watch(anchorListProvider());

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(anchorListProvider().future);
        ref.refresh(bannerProvider.future);
        ref.refresh(newsFirstPageProvider(context.localeCode).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: Column(
          children: [
            const HomeBannerCarousel(),
            anchorsAsync.when(
              loading: () => Column(
                children: [
                  HomeSectionTitle(
                    icon: 'assets/images/live-tv.png',
                    title: 'home.section.anchor_live'.tr(),
                    // subtitle: 'home.section.anchor_live_subtitle'.tr(),
                    onPressed: () => context.push(AppRoutes.anchorList),
                  ),
                  HomeAnchorLiveGrid(),
                ],
              ),
              error: (err, stack) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'home.error.load_failed'.tr(),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => ref.refresh(anchorListProvider().future),
                          child: Text('common.retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                  HomeSectionTitle(
                    icon: 'assets/images/news.png',
                    title: 'home.section.video_highlights'.tr(),
                    onPressed: () {},
                  ),
                  HomeVideoList(locale: context.localeCode),
                ],
              ),
              data: (page) => Column(
                children: [
                  HomeSectionTitle(
                    icon: 'assets/images/live-tv.png',
                    title: 'home.section.anchor_live'.tr(),
                    // subtitle: 'home.section.anchor_live_subtitle'.tr(),
                    onPressed: () => context.push(AppRoutes.anchorList),
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
