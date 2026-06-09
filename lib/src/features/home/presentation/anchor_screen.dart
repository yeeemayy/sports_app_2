import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_grid.dart';

class AnchorScreen extends ConsumerStatefulWidget {
  const AnchorScreen({super.key});

  @override
  ConsumerState<AnchorScreen> createState() => _AnchorScreenState();
}

class _AnchorScreenState extends ConsumerState<AnchorScreen> {
  bool _isManualRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final anchorsAsync = ref.watch(anchorListProvider());

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isManualRefreshing = true);
        try {
          ref.invalidate(anchorListProvider());
          await ref.read(anchorListProvider().future);
        } catch (_) {
          // error is displayed by the when() error builder
        } finally {
          if (mounted) setState(() => _isManualRefreshing = false);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: SafeArea(
          child: _isManualRefreshing
              ? HomeAnchorLiveGrid(padding: EdgeInsets.all(16))
              : anchorsAsync.when(
                  skipLoadingOnRefresh: false,
                  loading: () =>
                      HomeAnchorLiveGrid(padding: EdgeInsets.all(16)),
                  error: (err, stack) {
                    print(stack);
                    return Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .7,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'home.error.load_failed'.tr(),
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () =>
                                  ref.refresh(anchorListProvider().future),
                              child: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  data: (page) => page.data.isNotEmpty
                      ? HomeAnchorLiveGrid(
                          anchors: page.data,
                          padding: EdgeInsets.all(16),
                        )
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
                                Text(
                                  'home.anchor.no_live'.tr(),
                                  style: context.textTheme.titleMedium,
                                ),
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
