import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';

class HomeTabOthers extends ConsumerWidget {
  const HomeTabOthers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchorsAsync = ref.watch(anchorListProvider());

    return RefreshIndicator(
      onRefresh: () => ref.refresh(anchorListProvider().future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: Column(
          children: [
            HomeSectionTitle(
              icon: 'assets/images/live-tv.png',
              title: 'home.section.anchor_live'.tr(),
              onPressed: () {},
            ),
            anchorsAsync.when(
              loading: () => const HomeAnchorLiveGrid(),
              error: (err, stack) {
                print('$err\n$stack');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('home.error.load_failed'.tr()),
                  ),
                );
              },
              data: (page) => HomeAnchorLiveGrid(anchors: page.data),
            ),
          ],
        ),
      ),
    );
  }
}
