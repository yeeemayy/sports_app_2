import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/providers/banner_providers.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class HomeBannerCarousel extends ConsumerStatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  ConsumerState<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends ConsumerState<HomeBannerCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAsync = ref.watch(bannerProvider);
    final newsAsync = ref.watch(newsFirstPageProvider(context.localeCode));

    final bannerUrl = bannerAsync.valueOrNull?.cover;
    final articles = newsAsync.valueOrNull ?? [];

    final int itemCount = (bannerUrl != null ? 1 : 0) + articles.length;
    if (itemCount == 0) {
      return _shimmerPlaceholder();
    }

    return Column(
      children: [
        SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: itemCount,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              if (bannerUrl != null && index == 0) {
                return _carouselItem(
                  bannerUrl,
                  title: 'home.section.anchor_live'.tr(),
                  subtitle: 'home.section.anchor_live_subtitle'.tr(),
                  onTap: () => context.push(AppRoutes.anchorList),
                );
              }
              final article = articles[index - (bannerUrl != null ? 1 : 0)];
              return _carouselItem(
                article.imageUrl ?? '',
                title: article.title,
                subtitle: article.description.replaceAll(RegExp(r'<[^>]*>'), ''),
                onTap: article.imageUrl != null
                    ? () => context.push(AppRoutes.newsDetailPath(article.id))
                    : null,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _PageDots(count: itemCount, current: _currentPage),
      ],
    );
  }

  Widget _carouselItem(String url, {String? title, String? subtitle, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url.isEmpty
            ? const ColoredBox(color: Color(0xFFE0E0E0))
            : GestureDetector(
                onTap: onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: url,
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Skeletonizer(
                        enabled: true,
                        child: const ColoredBox(color: Colors.grey),
                      ),
                      errorBuilder: (context, url, error) =>
                          const ColoredBox(color: Color(0xFFE0E0E0)),
                    ),
                    if (title != null || subtitle != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (title != null)
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_right, color: Colors.white,)
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Skeletonizer(
          enabled: true,
          child: const SizedBox(height: 180, child: ColoredBox(color: Colors.grey)),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? context.appColors.accent : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
