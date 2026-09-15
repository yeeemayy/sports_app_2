import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/home/domain/models/banner_model.dart';
import 'package:shenghaotiyu/src/features/home/presentation/providers/banner_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:shenghaotiyu/src/features/anchor/domain/models/anchor_detail_model.dart';
import 'package:shenghaotiyu/src/features/anchor/presentation/anchor_chats_tab.dart';
import 'package:shenghaotiyu/src/features/anchor/presentation/anchor_video_fullscreen_page.dart';
import 'package:shenghaotiyu/src/features/anchor/presentation/providers/anchor_detail_providers.dart';

/// Owns the live-stream player's lifecycle and surface state, kept separate
/// from [_AnchorDetailScreenState] so the screen widget only deals with
/// composing UI, not player bookkeeping.
class _StreamPlaybackController extends ChangeNotifier {
  VideoPlayerController? _controller;
  String? _currentUrl;
  bool initialized = false;
  bool hasError = false;
  bool buffering = false;
  bool controlsVisible = false;
  Timer? _hideTimer;

  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _controller?.value.isPlaying ?? false;

  Future<void> start(String url) async {
    if (_controller != null) return;
    _currentUrl = url;
    hasError = false;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    controller.addListener(_onTick);
    try {
      await controller.initialize();
      initialized = true;
      controller.play();
      notifyListeners();
    } catch (_) {
      hasError = true;
      notifyListeners();
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null) return;
    var changed = false;
    if (controller.value.isBuffering != buffering) {
      buffering = controller.value.isBuffering;
      changed = true;
    }
    if (controller.value.hasError && !hasError) {
      hasError = true;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void toggleControlsVisible() {
    controlsVisible = !controlsVisible;
    notifyListeners();
    if (controlsVisible) _scheduleAutoHide();
  }

  void togglePlayback() {
    final controller = _controller;
    if (controller == null || !initialized) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    controlsVisible = true;
    notifyListeners();
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      controlsVisible = false;
      notifyListeners();
    });
  }

  Future<void> retry() async {
    final url = _currentUrl;
    await _teardownController();
    if (url != null) await start(url);
  }

  Future<void> _teardownController() async {
    _controller?.removeListener(_onTick);
    await _controller?.dispose();
    _controller = null;
    initialized = false;
    hasError = false;
    buffering = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }
}

class AnchorDetailScreen extends ConsumerStatefulWidget {
  const AnchorDetailScreen({super.key, required this.anchorId});

  final int anchorId;

  @override
  ConsumerState<AnchorDetailScreen> createState() => _AnchorDetailScreenState();
}

class _AnchorDetailScreenState extends ConsumerState<AnchorDetailScreen>
    with TickerProviderStateMixin {
  final _playback = _StreamPlaybackController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _playback.addListener(_onPlaybackChanged);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(bannerProvider);
    });
  }

  void _onPlaybackChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openFullscreen() async {
    final controller = _playback.controller;
    if (controller == null || !_playback.initialized) return;
    final wasPlaying = controller.value.isPlaying;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AnchorVideoFullscreenPage(controller: controller),
      ),
    );
    if (mounted && wasPlaying) controller.play();
  }

  void _ensureStreamStarted(AnchorDetailModel detail) {
    final url = detail.m3u8Url;
    if (_playback.controller == null && url != null && url.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _playback.controller == null) _playback.start(url);
      });
    }
  }

  @override
  void dispose() {
    _playback
      ..removeListener(_onPlaybackChanged)
      ..dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(anchorDetailProvider(widget.anchorId));
    detailAsync.whenData(_ensureStreamStarted);
    final bannerAsync = ref.watch(bannerProvider);

    return Scaffold(
      backgroundColor: context.appColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            _StreamSurface(
              detailAsync: detailAsync,
              playback: _playback,
              onFullscreen: _openFullscreen,
            ),
            Expanded(child: _buildBelowSection(detailAsync, bannerAsync)),
          ],
        ),
      ),
    );
  }

  // ─── Below-stream section ───────────────────────────────────────────────

  Widget _buildBelowSection(
    AsyncValue<AnchorDetailModel> detailAsync,
    AsyncValue<BannerModel> bannerAsync,
  ) {
    final colors = context.appColors;
    return detailAsync.when(
      loading: () => Center(
        child: Text(
          'anchor.detail.loading'.tr(),
          style: AppTextStyles.mono(11).copyWith(color: colors.text3, letterSpacing: 1.4),
        ),
      ),
      error: (_, _) => Center(
        child: Text(
          'anchor.detail.error.load_failed'.tr(),
          style: AppTextStyles.mono(11).copyWith(color: colors.text3),
        ),
      ),
      data: (detail) => Column(
        children: [
          _buildTabBar(),
          if (detail.notice.isNotEmpty) _NoticeBanner(notice: detail.notice),
          _RefAppBanner(bannerAsync: bannerAsync),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AnchorChatsTab(anchorId: widget.anchorId),
                _InfoTab(detail: detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.accent, width: 2),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextStyles.display(16, context).copyWith(letterSpacing: 0.08 * 16),
        unselectedLabelStyle: AppTextStyles.display(16, context).copyWith(letterSpacing: 0.08 * 16),
        labelColor: colors.text,
        unselectedLabelColor: colors.text3,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(height: 44, child: Text('anchor.detail.tab.chats'.tr().toUpperCase())),
          Tab(height: 44, child: Text('anchor.detail.tab.info'.tr().toUpperCase())),
        ],
      ),
    );
  }
}

// ─── Live stream surface (video + all overlays) ─────────────────────────────

class _StreamSurface extends StatelessWidget {
  const _StreamSurface({
    required this.detailAsync,
    required this.playback,
    required this.onFullscreen,
  });

  final AsyncValue<AnchorDetailModel> detailAsync;
  final _StreamPlaybackController playback;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final height = MediaQuery.sizeOf(context).width * 9 / 16;
    final detail = detailAsync.valueOrNull;

    return GestureDetector(
      onTap: playback.toggleControlsVisible,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            detailAsync.when(
              loading: () => ColoredBox(color: colors.ink2),
              error: (_, _) => ColoredBox(color: colors.ink2),
              data: (detail) => _StreamBackground(detail: detail, playback: playback),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xEB000000),
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            if (detailAsync.isLoading || (playback.controller != null && !playback.initialized && !playback.hasError))
              const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            if (playback.initialized && playback.buffering)
              const ColoredBox(
                color: Colors.black38,
                child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            if (playback.hasError) _StreamErrorOverlay(onRetry: playback.retry),
            if (detail != null && !playback.hasError && (detail.isLive == 0 || detail.m3u8Url == null))
              Center(
                child: Text(
                  'anchor.detail.offline'.tr(),
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
            AnimatedOpacity(
              opacity: playback.controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !playback.controlsVisible,
                child: Center(
                  child: GestureDetector(
                    onTap: playback.togglePlayback,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.lineStrong),
                      ),
                      child: Icon(
                        playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 16,
              child: Row(
                children: [
                  _FrostedIconButton(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  if (detail?.isLive == 1) ...[
                    const SizedBox(width: 10),
                    const _LivePulseBadge(),
                    const SizedBox(width: 8),
                    _FollowerChip(count: detail!.collect),
                  ],
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: playback.controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !playback.controlsVisible,
                  child: _FrostedIconButton(
                    onTap: onFullscreen,
                    size: 34,
                    borderRadius: 8,
                    child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            if (detail != null)
              Positioned(bottom: 16, left: 16, right: 16, child: _AnchorVideoStrip(detail: detail)),
          ],
        ),
      ),
    );
  }
}

class _StreamBackground extends StatelessWidget {
  const _StreamBackground({required this.detail, required this.playback});

  final AnchorDetailModel detail;
  final _StreamPlaybackController playback;

  @override
  Widget build(BuildContext context) {
    if (playback.initialized && playback.controller != null) {
      final controller = playback.controller!;
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return Image.network(
      detail.cover,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, url, error) => ColoredBox(color: context.appColors.ink2),
    );
  }
}

class _StreamErrorOverlay extends StatelessWidget {
  const _StreamErrorOverlay({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'anchor.detail.video.error'.tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text('anchor.detail.video.retry'.tr())),
          ],
        ),
      ),
    );
  }
}

// ─── Notice + partner-app banners ────────────────────────────────────────────

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.notice});

  final String notice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              'anchor.detail.info.notice_banner_label'.tr().toUpperCase(),
              style: AppTextStyles.mono(9).copyWith(color: Colors.white, letterSpacing: 1.4, height: 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Marquee(
              text: notice,
              style: AppTextStyles.body(12).copyWith(color: colors.text2),
              scrollAxis: Axis.horizontal,
              blankSpace: 30,
              velocity: 50,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _RefAppBanner extends StatelessWidget {
  const _RefAppBanner({required this.bannerAsync});

  final AsyncValue<BannerModel> bannerAsync;

  @override
  Widget build(BuildContext context) {
    return bannerAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (banner) {
        final apps = banner.refApp
            .where((app) => app.name != null && app.name!.isNotEmpty)
            .toList();
        if (apps.isEmpty) return const SizedBox.shrink();

        final colors = context.appColors;
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.symmetric(horizontal: BorderSide(color: colors.line, width: 0.5)),
          ),
          child: Row(
            children: [
              for (int i = 0; i < apps.length; i++) ...[
                if (i > 0)
                  VerticalDivider(
                    width: 1,
                    thickness: 0.5,
                    color: colors.lineStrong,
                    indent: 12,
                    endIndent: 12,
                  ),
                Expanded(
                  child: Center(
                    child: _RefAppButton(icon: apps[i].icon, name: apps[i].name!, url: apps[i].url),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Info tab ─────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.detail});

  final AnchorDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Card(
          elevation: 0,
          color: colors.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colors.line, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.accent, width: 2),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: detail.avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Skeletonizer(enabled: true, child: ColoredBox(color: colors.surface2)),
                          errorBuilder: (context, url, error) => ColoredBox(color: colors.surface2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.nickname,
                            style: AppTextStyles.display(18, context).copyWith(color: colors.text),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: colors.accentEcho, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                '${detail.collect}',
                                style: AppTextStyles.mono(11).copyWith(color: colors.text2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (detail.isLive == 1) const _LivePulseBadge(),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 0, color: colors.lineStrong),
                const SizedBox(height: 16),
                _InfoRow(label: 'anchor.detail.info.title'.tr(), value: detail.title),
                const SizedBox(height: 14),
                _InfoRow(label: 'anchor.detail.info.followers'.tr(), value: '${detail.collect}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Frosted glass icon button ───────────────────────────────────────────────

class _FrostedIconButton extends StatelessWidget {
  const _FrostedIconButton({
    required this.onTap,
    required this.child,
    this.size = 38,
    this.borderRadius,
  });

  final VoidCallback onTap;
  final Widget child;
  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = borderRadius ?? size / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: colors.lineStrong, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─── Live pulse badge ─────────────────────────────────────────────────────────

class _LivePulseBadge extends StatefulWidget {
  const _LivePulseBadge();

  @override
  State<_LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<_LivePulseBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: colors.live, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'anchor.detail.live'.tr(),
            style: AppTextStyles.display(
              10,
              context,
            ).copyWith(color: Colors.white, letterSpacing: 0.12 * 10, height: 1),
          ),
        ],
      ),
    );
  }
}

// ─── Follower count chip ─────────────────────────────────────────────────────

class _FollowerChip extends StatelessWidget {
  const _FollowerChip({required this.count});

  final int count;

  String _format(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.lineStrong, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline_outlined, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(_format(count), style: AppTextStyles.mono(11).copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// ─── Anchor strip overlaid on video bottom ───────────────────────────────────

class _AnchorVideoStrip extends StatelessWidget {
  const _AnchorVideoStrip({required this.detail});

  final AnchorDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.accent, width: 2),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: detail.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Skeletonizer(enabled: true, child: ColoredBox(color: colors.surface2)),
              errorBuilder: (context, url, error) => ColoredBox(color: colors.surface2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                detail.nickname.toUpperCase(),
                style: AppTextStyles.display(17, context).copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                detail.title.toUpperCase(),
                style: AppTextStyles.mono(10).copyWith(color: Colors.grey.shade300, letterSpacing: 1.4),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Ref-app button ───────────────────────────────────────────────────────────

class _RefAppButton extends StatelessWidget {
  final String icon;
  final String name;
  final String url;
  const _RefAppButton({required this.icon, required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(imageUrl: icon, height: 35),
          const SizedBox(width: 10),
          Text(name, style: context.textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// ─── Info row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mono(10).copyWith(color: colors.text3, letterSpacing: 1.6),
        ),
        const SizedBox(height: 5),
        Text(value, style: context.textTheme.bodyMedium?.copyWith(color: colors.text)),
      ],
    );
  }
}
