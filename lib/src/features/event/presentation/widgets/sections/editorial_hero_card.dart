import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sections/shared_section_widgets.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

const _kHPad = 22.0;

class EditorialHeroCard extends StatelessWidget {
  const EditorialHeroCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 22),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.newsDetailPath(article.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: context.appColors.surface2),
                  errorBuilder: (_, _, _) =>
                      Container(color: context.appColors.surface2),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x0D0E0E0E),
                        Color(0xD90E0E0E),
                        Color(0xFF0E0E0E),
                      ],
                      stops: [0, 0.70, 1],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionChip(label: '● ${'home.featured'.tr()}', accent: true),
                        const Spacer(),
                        Text(
                          article.description.isNotEmpty
                              ? article.description.toUpperCase()
                              : '',
                          style: AppTextStyles.mono(9).copyWith(
                            color: Colors.grey,
                            letterSpacing: 9 * 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          article.title.toUpperCase(),
                          style: AppTextStyles.display(
                            28,
                            context,
                          ).copyWith(color: Colors.white, height: 0.9),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          DateFormat(
                            context.locale.languageCode == 'zh'
                                ? 'MMMdd日, yyyy HH:mm'
                                : 'dd MMM, yyyy HH:mm',
                            context.locale.languageCode,
                          ).format(DateTime.parse(article.createdAt)),
                          style: AppTextStyles.mono(10).copyWith(
                            color: context.appColors.text2,
                            letterSpacing: 10 * 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
