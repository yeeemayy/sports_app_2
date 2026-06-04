import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHPad = 22.0;

class TrendingNewsGrid extends StatelessWidget {
  const TrendingNewsGrid({super.key, required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'home.trending'.tr(),
                style: AppTextStyles.display(
                  22,
                  context,
                ).copyWith(color: context.appColors.text),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.news),
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(10).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 10 * 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kHPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < articles.length && i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: TrendingNewsCard(article: articles[i])),
              ],
            ],
          ),
        ),
        if (articles.length > 2) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kHPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 2; i < articles.length && i < 4; i++) ...[
                  if (i > 2) const SizedBox(width: 12),
                  Expanded(child: TrendingNewsCard(article: articles[i])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class TrendingNewsCard extends StatelessWidget {
  const TrendingNewsCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final category = article.keywords.split(',').first.trim().toUpperCase();

    return GestureDetector(
      onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) =>
                            Container(color: context.appColors.surface2),
                      )
                    else
                      Container(color: context.appColors.surface2),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.display(10, context).copyWith(
                            color: context.appColors.ink,
                            letterSpacing: 10 * 0.08,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title.toUpperCase(),
                    style: AppTextStyles.display(
                      15,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1.05),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      context.locale.languageCode == 'zh'
                          ? 'MMMdd日, yyyy HH:mm'
                          : 'dd MMM, yyyy HH:mm',
                      context.locale.languageCode,
                    ).format(DateTime.parse(article.createdAt)),
                    style: AppTextStyles.mono(9).copyWith(
                      color: context.appColors.text3,
                      letterSpacing: 9 * 0.12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
