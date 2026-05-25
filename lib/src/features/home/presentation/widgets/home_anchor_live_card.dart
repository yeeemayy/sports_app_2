import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';

class HomeAnchorLiveCard extends StatelessWidget {
  final AnchorModel? anchor;
  final bool _isLoading;
  final VoidCallback? onTap;

  const HomeAnchorLiveCard({super.key, this.anchor, this.onTap}) : _isLoading = false;

  const HomeAnchorLiveCard.loading({super.key}) : anchor = null, _isLoading = true, onTap = null;

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _LoadingCard();

    final isLive = anchor?.isLive == 1;
    final hasCover = anchor?.cover.isNotEmpty ?? false;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background cover image
            if (hasCover)
              CachedNetworkImage(
                imageUrl: anchor!.cover,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: context.appColors.surface2),
                errorBuilder: (_, _, _) => Container(color: context.appColors.surface2),
              )
            else
              Container(color: context.appColors.surface2),

            // Bottom gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                  ),
                ),
              ),
            ),

            // Top row: Live badge + view count
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'home.anchor.live_badge'.tr(),
                        style: AppTextStyles.display(
                          11,
                          context,
                        ).copyWith(color: Colors.white, letterSpacing: 11 * 0.04),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          _formatCount(anchor?.collect ?? 0),
                          style: AppTextStyles.display(11, context).copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom row: avatar + name + followers
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: anchor?.avatarUrl ?? '',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: Colors.white24),
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.white24,
                        child: const Icon(Icons.person, color: Colors.white54, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          anchor?.nickname ?? '',
                          style: AppTextStyles.display(
                            13,
                            context,
                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3),
                        Text(
                          anchor?.title ?? '',
                          style: AppTextStyles.display(10, context).copyWith(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isLive ? context.appColors.accent : Colors.grey.shade300,
                    child: Image.asset(
                      'assets/images/equalizer.gif',
                      color: Colors.white,
                      height: 20,
                      width: 20,
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

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(color: Colors.grey.shade300),
      ),
    );
  }
}
