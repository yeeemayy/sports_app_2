import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/video/domain/models/video_model.dart';
import 'package:sports_app/src/features/video/presentation/providers/video_providers.dart';
import 'package:sports_app/src/features/video/presentation/widgets/home_video_card.dart';
import 'package:sports_app/src/routes/app_routes.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoListProvider(locale: locale, page: page));

    return videosAsync.when(
      loading: () => _VideoGrid(
        itemCount: 6,
        itemBuilder: (_, index) => const HomeVideoCard.loading(),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('home.error.load_failed'.tr())),
      ),
      data: (response) {
        if (response.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text('home.error.load_failed'.tr())),
          );
        }
        return _VideoGrid(
          itemCount: response.list.length,
          itemBuilder: (context, index) {
            final video = response.list[index];
            return HomeVideoCard(
              video: video,
              onTap: onVideoTap != null
                  ? () => onVideoTap!(video)
                  : () => context.push(
                        AppRoutes.videoDetailPath(
                          video.id,
                          currentPage: page,
                          lastPage: response.meta.lastPage,
                        ),
                      ),
            );
          },
        );
      },
    );
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
