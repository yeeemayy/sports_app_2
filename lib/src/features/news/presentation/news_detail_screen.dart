import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.newsId});

  final int newsId;

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  // Inline `line-height: NNpx` values are inflated by flutter_html vs browsers.
  // Strip them so flutter_html uses its default line spacing.
  // Also strip empty <p><br/></p> spacer paragraphs — flutter_html renders each
  // as a full paragraph height, producing excessive blank space.
  String _cleanHtml(String html) {
    var result = html.replaceAll(RegExp(r'line-height\s*:\s*[^;"}]+;?\s*'), '');
    result = result.replaceAll('src="/https://', 'src="https://');
    result = result.replaceAll(RegExp(r'<p[^>]*>\s*(?:<span[^>]*>\s*(?:<br\s*/?>\s*)?</span>\s*)*(?:<br\s*/?>)?\s*</p>'), '');
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = _locale(context);
    final asyncDetail = ref.watch(newsDetailProvider(newsId, locale));

    return asyncDetail.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('news.details'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: const _NewsDetailSkeleton(),
      ),
      error: (e, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.showErrorDialog(title: 'news.detail_error'.tr(), error: e);
          }
        });
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('news.detail_error'.tr())),
        );
      },
      data: (detail) => Scaffold(
        appBar: AppBar(
          title: Text('news.details'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.4),
              ),
              if (detail.createdAtBj != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    detail.createdAtBj!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // if (detail.imageUrl != null && detail.imageUrl!.isNotEmpty)
              //   _CoverImage(url: detail.imageUrl!),
              Html(
                data: _cleanHtml(detail.content),
                style: {
                  "*": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                  "p": Style(margin: Margins.only(bottom: 20)),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsDetailSkeleton extends StatelessWidget {
  const _NewsDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appTheme.shimmerBase,
      highlightColor: context.appTheme.shimmerHighlight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: double.infinity, height: 18),
            const SizedBox(height: 6),
            _SkeletonBox(width: double.infinity, height: 18),
            const SizedBox(height: 6),
            _SkeletonBox(width: 200, height: 18),
            const SizedBox(height: 10),
            _SkeletonBox(width: 140, height: 13),
            const SizedBox(height: 20),
            _SkeletonBox(width: double.infinity, height: 220),
            const SizedBox(height: 20),
            for (int i = 0; i < 6; i++) ...[
              _SkeletonBox(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              _SkeletonBox(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              _SkeletonBox(width: 180, height: 14),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: context.appTheme.shimmerBase,
        highlightColor: context.appTheme.shimmerHighlight,
        child: Container(width: double.infinity, height: 220, color: Colors.white),
      ),
      errorBuilder: (context, url, error) => Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}
