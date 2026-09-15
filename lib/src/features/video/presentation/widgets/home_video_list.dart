import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';
import 'package:shenghaotiyu/src/features/video/presentation/providers/video_providers.dart';
import 'package:shenghaotiyu/src/features/video/presentation/widgets/home_video_card.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

class HomeVideoList extends ConsumerWidget {
  const HomeVideoList({
    super.key,
    required this.locale,
    this.page = 1,
    this.onVideoTap,
  });

  final String locale;
  final int page;
  final void Function(VideoModel video)? onVideoTap;

  void _openVideo(BuildContext context, VideoModel video, int lastPage) {
    if (onVideoTap != null) {
      onVideoTap!(video);
      return;
    }
    context.push(
      AppRoutes.videoDetailPath(video.id, currentPage: page, lastPage: lastPage),
    );
  }

  Widget _buildMessage(String message) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Text(message)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(
      videoListProvider(locale: locale, page: page),
    );

    if (videosAsync.isLoading) {
      return _VideoGrid.placeholder(count: 6);
    }
    if (videosAsync.hasError) {
      return _buildMessage('home.error.load_failed'.tr());
    }

    final response = videosAsync.requireValue;
    if (response.list.isEmpty) {
      return _buildMessage('home.error.load_failed'.tr());
    }

    return _VideoGrid(
      videos: response.list,
      onTap: (video) => _openVideo(context, video, response.meta.lastPage),
    );
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid({required List<VideoModel> videos, required this.onTap})
    : _videos = videos,
      _placeholderCount = 0;

  const _VideoGrid.placeholder({required int count})
    : _videos = const [],
      _placeholderCount = count,
      onTap = null;

  final List<VideoModel> _videos;
  final int _placeholderCount;
  final void Function(VideoModel video)? onTap;

  static const _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveBreakpoints.of(context).largerThan(MOBILE) ? 3 : 2;
    final count = _placeholderCount > 0 ? _placeholderCount : _videos.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
        childAspectRatio: 16 / 9,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (_placeholderCount > 0) return const HomeVideoCard.loading();
        final video = _videos[index];
        return HomeVideoCard(video: video, onTap: () => onTap!(video));
      },
    );
  }
}
