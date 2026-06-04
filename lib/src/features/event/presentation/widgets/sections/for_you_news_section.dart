import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/news/domain/models/news_article.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHPad = 22.0;

class ForYouNewsSection extends StatelessWidget {
  const ForYouNewsSection({super.key, required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 12),
          child: Text(
            'home.for_you_news'.tr(),
            style: AppTextStyles.display(22, context)
                .copyWith(color: context.appColors.text),
          ),
        ),
        for (int i = 0; i < articles.length; i++) ...[
          _ForYouNewsRow(article: articles[i]),
          if (i < articles.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kHPad),
              child: Divider(color: context.appColors.line, thickness: 0.5, height: 1),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ForYouNewsRow extends StatelessWidget {
  const _ForYouNewsRow({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dateStr = DateFormat(
      context.locale.languageCode == 'zh' ? 'MMMdd日, HH:mm' : 'dd MMM, HH:mm',
      context.locale.languageCode,
    ).format(DateTime.parse(article.createdAt));

    return InkWell(
      onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: article.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      width: 120,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 120,
                        height: 96,
                        color: colors.surface,
                      ),
                      errorBuilder: (_, _, _) => Container(
                        width: 120,
                        height: 96,
                        color: colors.surface2,
                        child: Icon(Icons.broken_image_outlined, color: colors.text3),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 96,
                      color: colors.surface2,
                      child: Icon(Icons.article_outlined, color: colors.text3, size: 28),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(17, context)
                        .copyWith(color: colors.text, height: 1.05),
                  ),
                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(12)
                          .copyWith(color: colors.text3, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '● $dateStr',
                    style: AppTextStyles.mono(9)
                        .copyWith(color: colors.text3, letterSpacing: 1.08),
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
