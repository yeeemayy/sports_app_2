import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';

class HomeVideoCard extends StatelessWidget {
  const HomeVideoCard({super.key, required this.video, required this.onTap})
    : _loading = false;

  const HomeVideoCard.loading({super.key})
    : video = null,
      onTap = null,
      _loading = true;

  final VideoModel? video;
  final VoidCallback? onTap;
  final bool _loading;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _VideoCardSkeleton();

    final hasThumbnail = video!.thumbnailPath.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasThumbnail)
                    CachedNetworkImage(
                      imageUrl: video!.thumbnailPath,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Skeletonizer(
                        enabled: true,
                        child: const ColoredBox(color: Colors.grey),
                      ),
                      errorBuilder: (context, e, s) =>
                          const ColoredBox(color: Color(0xFF333333)),
                    )
                  else
                    const ColoredBox(color: Color(0xFF333333)),
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white70,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            video!.title,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VideoCardSkeleton extends StatelessWidget {
  const _VideoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
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
