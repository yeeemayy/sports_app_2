import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/domain/models/news_detail.dart';
import 'package:sports_app/src/features/news/presentation/providers/news_providers.dart';

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.newsId});

  final int newsId;

  static final _placeholder = NewsDetail(
    id: 0,
    title: 'Lorem ipsum dolor sit amet consectetur',
    description: '',
    content: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>'
        '<p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
        '<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>'
        '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>'
        '<p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
        '<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>'
        '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>'
        '<p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
        '<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>'
        '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>'
        '<p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
        '<p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>',
    imageUrl: null,
    keywords: '',
    createdAt: '',
    createdAtBj: '2026-01-01 00:00:00',
    slugUrl: '',
    browse: 0,
    category: 0,
  );

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  // Inline `line-height: NNpx` values are inflated by flutter_html vs browsers.
  // Strip them so flutter_html uses its default line spacing.
  // Also strip empty <p><br/></p> spacer paragraphs — flutter_html renders each
  // as a full paragraph height, producing excessive blank space.
  String _cleanHtml(String html, {String? heroImageUrl}) {
    var result = html.replaceAll(RegExp(r'line-height\s*:\s*[^;"}]+;?\s*'), '');
    result = result.replaceAll('src="/https://', 'src="https://');
    if (heroImageUrl != null) {
      result = result.replaceFirst(
        RegExp(r'<img\b[^>]*src="' + RegExp.escape(heroImageUrl) + r'"[^>]*/?>'),
        '',
      );
    }
    result = result.replaceAll(RegExp(r'<p[^>]*>\s*(?:<span[^>]*>\s*(?:<br\s*/?>\s*)?</span>\s*)*(?:<br\s*/?>)?\s*</p>'), '');
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = _locale(context);
    final colors = context.appColors;
    final asyncDetail = ref.watch(newsDetailProvider(newsId, locale));

    if (asyncDetail.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.showErrorDialog(title: 'news.detail_error'.tr(), error: asyncDetail.error!);
        }
      });
      return Scaffold(
        backgroundColor: colors.ink,
        appBar: _buildAppBar(context, colors),
        body: Center(
          child: Text('news.detail_error'.tr(), style: TextStyle(color: colors.text2)),
        ),
      );
    }

    final isLoading = asyncDetail.isLoading;
    final detail = asyncDetail.valueOrNull ?? _placeholder;
    final hasImage = detail.imageUrl?.isNotEmpty == true;

    return Skeletonizer(
      enabled: isLoading,
      child: Scaffold(
        backgroundColor: colors.ink,
        body: CustomScrollView(
          slivers: [
            // ── Collapsing hero image / sticky AppBar ──
            SliverAppBar(
              backgroundColor: colors.ink,
              expandedHeight: hasImage || isLoading ? 260.0 : 0,
              pinned: true,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.lineStrong, width: 0.5),
                  ),
                  child: Icon(Icons.arrow_circle_left_outlined, color: Colors.white, size: 24),
                ),
              ),
              flexibleSpace: hasImage || isLoading
                  ? FlexibleSpaceBar(
                      background: hasImage
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: detail.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: colors.surface2),
                                  errorBuilder: (context, url, error) =>
                                      Container(color: colors.surface2),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        colors.ink.withValues(alpha: 0.9),
                                      ],
                                      stops: const [0.45, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(color: colors.surface2),
                    )
                  : null,
            ),
            // ── Article content ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      detail.title,
                      style: AppTextStyles.display(28, context).copyWith(
                        color: colors.text,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Date
                    if (detail.createdAtBj != null)
                      Text(
                        detail.createdAtBj!,
                        style: AppTextStyles.mono(10).copyWith(
                          color: colors.text3,
                          letterSpacing: 1.6,
                        ),
                      ),
                    const SizedBox(height: 22),
                    // HTML body
                    Skeleton.replace(
                      replacement: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < 6; i++) ...[
                            Container(height: 14, width: double.infinity, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(height: 14, width: double.infinity, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(height: 14, width: 180, color: Colors.white),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                      child: Html(
                        data: _cleanHtml(detail.content, heroImageUrl: detail.imageUrl),
                        style: {
                          "*": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                          "p": Style(margin: Margins.only(bottom: 20)),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppColors colors) {
    return AppBar(
      backgroundColor: colors.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: colors.lineStrong, width: 0.5),
          ),
          child: Icon(Icons.arrow_circle_left_outlined, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

