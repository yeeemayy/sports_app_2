import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';

class HomeAnchorLiveCard extends StatelessWidget {
  final AnchorModel? anchor;
  final bool _isLoading;
  final VoidCallback? onTap;

  const HomeAnchorLiveCard({super.key, this.anchor, this.onTap}) : _isLoading = false;

  const HomeAnchorLiveCard.loading({super.key}) : anchor = null, _isLoading = true, onTap = null;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _LoadingCard();
    final isLive = anchor?.isLive == 1;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            anchor?.cover ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade800,
                                highlightColor: Colors.grey.shade600,
                                child: const ColoredBox(color: Colors.grey),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Image.network failed: $error');
                              return const ColoredBox(color: Color(0xFF333333));
                            },
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            anchor?.avatarUrl ??
                                            'https://placehold.co/400x400/FFFFFF/898989.png?text=A',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey.shade600,
                                          highlightColor: Colors.grey.shade400,
                                          child: const ColoredBox(color: Colors.grey),
                                        ),
                                        errorBuilder: (context, url, error) =>
                                            const ColoredBox(color: Color(0xFF333333)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      anchor?.nickname ?? '',
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    anchor != null ? '${anchor!.collect}' : '0',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isLive) Container(color: Colors.black.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -8,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: isLive ? AppColors.primary : Colors.grey.shade300,
                  child: const Icon(Icons.bar_chart, color: Colors.white, size: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            anchor?.title ?? '',
            style: context.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 10),
          // Title line 1
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          // Title line 2 (shorter)
          FractionallySizedBox(
            widthFactor: 0.65,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
