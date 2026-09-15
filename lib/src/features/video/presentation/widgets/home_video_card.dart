import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';

/// A "poster" style card: the title is overlaid on the thumbnail behind a
/// bottom gradient scrim, rather than sitting in a separate row below it.
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

  static const _cornerRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cornerRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _loading
            ? const _CardSkeleton()
            : GestureDetector(onTap: onTap, child: _CardContent(video: video!)),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = video.thumbnailPath.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        hasThumbnail
            ? CachedNetworkImage(
                imageUrl: video.thumbnailPath,
                fit: BoxFit.cover,
                placeholder: (context, _) => Skeletonizer(
                  enabled: true,
                  child: const ColoredBox(color: Colors.grey),
                ),
                errorBuilder: (context, e, s) => const _Placeholder(),
              )
            : const _Placeholder(),
        const _PlayGlyph(),
        _TitleScrim(title: video.title),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Color(0xFF333333));
}

class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
      ),
    );
  }
}

class _TitleScrim extends StatelessWidget {
  const _TitleScrim({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.grey.shade300),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
