import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';

const _placeholder = NewsArticle(
  id: 0,
  title: 'Loading news article title here',
  description: 'Loading description text for the news article here',
  keywords: '',
  createdAt: '2024-01-01T00:00:00Z',
  slugUrl: '',
  browse: 0,
  category: 0,
);

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.categoryLabel = '',
    this.grid = false,
  }) : _loading = false;

  const NewsCard.loading({super.key, this.grid = false})
    : article = null,
      onTap = null,
      categoryLabel = '',
      _loading = true;

  final NewsArticle? article;
  final VoidCallback? onTap;
  final String categoryLabel;
  final bool _loading;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final a = article ?? _placeholder;
    if (grid) {
      return Skeletonizer(enabled: _loading, child: _buildGrid(context, a));
    }
    return Skeletonizer(enabled: _loading, child: _buildList(context, a));
  }

  Widget _buildList(BuildContext context, NewsArticle a) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(url: a.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryLabel.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          categoryLabel.toUpperCase(),
                          style: AppTextStyles.mono(
                            9,
                          ).copyWith(color: colors.accent, letterSpacing: 1.44),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                  Text(
                    a.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      17,
                      context,
                    ).copyWith(color: colors.text, height: 1.05),
                  ),
                  if (a.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        12,
                      ).copyWith(color: colors.text3, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '● ${_timeAgo(a.createdAt)}',
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: colors.text3, letterSpacing: 1.08),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, NewsArticle a) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _GridCoverImage(url: a.imageUrl),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryLabel.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryLabel.toUpperCase(),
                          style: AppTextStyles.mono(
                            8,
                          ).copyWith(color: colors.accent, letterSpacing: 1.44),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    a.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      14,
                      context,
                    ).copyWith(color: colors.text, height: 1.1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '● ${_timeAgo(a.createdAt)}',
                    style: AppTextStyles.mono(
                      8,
                    ).copyWith(color: colors.text3, letterSpacing: 1.08),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} MIN AGO';
      if (diff.inHours < 24) return '${diff.inHours} HR AGO';
      if (diff.inDays < 30) return '${diff.inDays} DAYS AGO';
      return '${(diff.inDays / 30).floor()} MO AGO';
    } catch (_) {
      return iso;
    }
  }
}

class _GridCoverImage extends StatelessWidget {
  const _GridCoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (url == null || url!.isEmpty) {
      return ColoredBox(
        color: colors.surface2,
        child: Icon(Icons.article_outlined, color: colors.text3, size: 24),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Skeletonizer(enabled: true, child: ColoredBox(color: colors.surface)),
      errorBuilder: (context, url, error) => ColoredBox(
        color: colors.surface2,
        child: Icon(Icons.broken_image_outlined, color: colors.text3),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const w = 120.0;
    const h = 96.0;
    final colors = context.appColors;
    if (url == null || url!.isEmpty) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.article_outlined, color: colors.text3, size: 28),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: w,
        height: h,
        fit: BoxFit.cover,
        placeholder: (context, url) => Skeletonizer(
          enabled: true,
          child: Container(width: w, height: h, color: colors.surface),
        ),
        errorBuilder: (context, url, error) => Container(
          width: w,
          height: h,
          color: colors.surface2,
          child: Icon(Icons.broken_image_outlined, color: colors.text3),
        ),
      ),
    );
  }
}
