import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/home_tab_others.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/routes/app_routes.dart';

class AnchorScreen extends ConsumerWidget {
  const AnchorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorsAsync = ref.watch(anchorListProvider());

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(anchorListProvider().future);
        // ref.refresh(bannerProvider.future);
        // ref.refresh(newsFirstPageProvider(context.localeCode).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: SafeArea(
          child: anchorsAsync.when(
            loading: () => HomeAnchorLiveGrid(),
            error: (err, stack) => Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .7,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'home.error.load_failed'.tr(),
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.refresh(anchorListProvider().future),
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
            data: (page) => page.data.isNotEmpty
                ? HomeAnchorLiveGrid(anchors: page.data)
                : Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_camera_front_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text('home.anchor.no_live'.tr(), style: context.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        Text(
                          'home.anchor.no_live_subtitle'.tr(),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
