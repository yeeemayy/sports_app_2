import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/domain/models/banner_model.dart';
import 'package:sports_app/src/features/home/presentation/providers/banner_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:sports_app/src/features/anchor/domain/models/anchor_detail_model.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_chats_tab.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_video_fullscreen_page.dart';
import 'package:sports_app/src/features/anchor/presentation/providers/anchor_detail_providers.dart';

class AnchorDetailScreen extends ConsumerStatefulWidget {
  const AnchorDetailScreen({super.key, required this.anchorId});

  final int anchorId;

  @override
  ConsumerState<AnchorDetailScreen> createState() => _AnchorDetailScreenState();
}

class _AnchorDetailScreenState extends ConsumerState<AnchorDetailScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late final TabController _tabController;
  bool _videoInitialized = false;
  bool _videoError = false;
  bool _isBuffering = false;
  String? _currentM3u8Url;
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _onVideoTap();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(bannerProvider);
    });
  }

  Future<void> _initVideoPlayer(String m3u8Url) async {
    if (_videoController != null) return;
    _currentM3u8Url = m3u8Url;
    if (mounted) setState(() => _videoError = false);
    _videoController = VideoPlayerController.networkUrl(Uri.parse(m3u8Url));
    _videoController!.addListener(_onVideoUpdate);
    try {
      await _videoController!.initialize();
      if (mounted) {
        setState(() => _videoInitialized = true);
        _videoController!.play();
      }
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final controller = _videoController;
    if (controller == null) return;

    final buffering = controller.value.isBuffering;
    if (buffering != _isBuffering) {
      setState(() => _isBuffering = buffering);
    }

    if (controller.value.hasError && !_videoError) {
      setState(() => _videoError = true);
    }
  }

  void _onVideoTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  void _togglePlayPause() {
    final controller = _videoController;
    if (controller == null || !_videoInitialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
    _onVideoTap();
  }

  Future<void> _openFullscreen() async {
    if (_videoController == null || !_videoInitialized) return;
    final wasPlaying = _videoController!.value.isPlaying;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AnchorVideoFullscreenPage(controller: _videoController!),
      ),
    );
    if (mounted && wasPlaying && _videoController != null) {
      _videoController!.play();
    }
  }

  Future<void> _retryVideo() async {
    final url = _currentM3u8Url;
    if (url == null) return;
    _videoController?.removeListener(_onVideoUpdate);
    await _videoController?.dispose();
    _videoController = null;
    setState(() {
      _videoInitialized = false;
      _videoError = false;
      _isBuffering = false;
    });
    await _initVideoPlayer(url);
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(anchorDetailProvider(widget.anchorId), (_, next) {
      next.whenData((detail) {
        if (_videoController == null &&
            detail.m3u8Url != null &&
            detail.m3u8Url!.isNotEmpty) {
          _initVideoPlayer(detail.m3u8Url!);
        }
      });
    });

    final detailAsync = ref.watch(anchorDetailProvider(widget.anchorId));
    final bannerAsync = ref.watch(bannerProvider);

    return Scaffold(
      backgroundColor: context.appColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoSection(detailAsync),
            Expanded(child: _buildBelowSection(detailAsync, bannerAsync)),
          ],
        ),
      ),
    );
  }

  // ─── Video section ──────────────────────────────────────────────────────────

  Widget _buildVideoSection(AsyncValue<AnchorDetailModel> detailAsync) {
    final colors = context.appColors;
    final videoHeight = MediaQuery.sizeOf(context).width * 9 / 16;

    return GestureDetector(
      onTap: _onVideoTap,
      child: SizedBox(
        height: videoHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: Raw video / cover image ──
            detailAsync.when(
              loading: () => ColoredBox(color: colors.ink2),
              error: (_, _) => ColoredBox(color: colors.ink2),
              data: (detail) => _buildVideoBackground(detail),
            ),

            // ── Layer 2: Gradient overlay ──
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000), // 40% black
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xEB000000), // 92% black
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),

            // ── Layer 3: API loading ──
            if (detailAsync.isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: colors.text,
                  strokeWidth: 2,
                ),
              ),

            // ── Layer 4: Video controller init spinner ──
            if (_videoController != null && !_videoInitialized && !_videoError)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),

            // ── Layer 5: Buffering ──
            if (_videoInitialized && _isBuffering)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),

            // ── Layer 6: Video error ──
            if (_videoError)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'anchor.detail.video.error'.tr(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _retryVideo,
                        child: Text('anchor.detail.video.retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Layer 7: Offline ──
            if (detailAsync.valueOrNull != null &&
                !_videoError &&
                (detailAsync.valueOrNull!.isLive == 0 ||
                    detailAsync.valueOrNull!.m3u8Url == null))
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    'anchor.detail.offline'.tr(),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            // ── Layer 8: Controls (play/pause) — animated ──
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.lineStrong),
                      ),
                      child: Icon(
                        _videoController?.value.isPlaying == true
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colors.text,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Layer 9: Top bar — back button + live badge + follower chip ──
            Positioned(
              top: 8,
              left: 8,
              right: 16,
              child: Row(
                children: [
                  _FrostedIconButton(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colors.text,
                      size: 18,
                    ),
                  ),
                  Spacer(),
                  if (detailAsync.valueOrNull?.isLive == 1) ...[
                    const SizedBox(width: 10),
                    const _LivePulseBadge(),
                    const SizedBox(width: 8),
                    _FollowerChip(count: detailAsync.valueOrNull!.collect),
                  ],
                ],
              ),
            ),

            // ── Layer 11: Fullscreen button (top-right) — animated ──
            Positioned(
              bottom: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _FrostedIconButton(
                    onTap: _openFullscreen,
                    size: 34,
                    borderRadius: 8,
                    child: Icon(
                      Icons.fullscreen_rounded,
                      color: colors.text,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            // ── Layer 12: Anchor strip (bottom overlay) ──
            if (detailAsync.valueOrNull != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _AnchorVideoStrip(detail: detailAsync.valueOrNull!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoBackground(AnchorDetailModel detail) {
    if (_videoInitialized && _videoController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: detail.cover,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Skeletonizer(
        enabled: true,
        child: ColoredBox(color: context.appColors.ink2),
      ),
      errorBuilder: (context, url, error) =>
          ColoredBox(color: context.appColors.ink2),
    );
  }

  // ─── Below-video section ────────────────────────────────────────────────────

  Widget _buildBelowSection(
    AsyncValue<AnchorDetailModel> detailAsync,
    AsyncValue<BannerModel> bannerAsync,
  ) {
    final colors = context.appColors;
    return detailAsync.when(
      loading: () => Center(
        child: Text(
          'anchor.detail.loading'.tr(),
          style: AppTextStyles.mono(11).copyWith(
            color: colors.text3,
            letterSpacing: 1.4,
          ),
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
          if (detail.notice.isNotEmpty) _buildNoticeBanner(detail.notice),
          _buildRefAppBanner(bannerAsync),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AnchorChatsTab(anchorId: widget.anchorId),
                _buildInfoTab(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Arena-themed notice bar: accent label pill on the left, scrolling text on the right.
  Widget _buildNoticeBanner(String notice) {
    final colors = context.appColors;
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          // Label
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
              style: AppTextStyles.mono(9).copyWith(
                color: const Color(0xFF0E0E0E),
                letterSpacing: 1.4,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Scrolling text
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

  Widget _buildRefAppBanner(AsyncValue<BannerModel> bannerAsync) {
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
            border: Border.symmetric(
              horizontal: BorderSide(color: colors.line, width: 0.5),
            ),
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
                    child: _RefAppButton(
                      icon: apps[i].icon,
                      name: apps[i].name!,
                      url: apps[i].url,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
        // Gap-24 between tabs (right-only label padding simulates flex gap)
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.accent, width: 2),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextStyles.display(16, context).copyWith(
          letterSpacing: 0.08 * 16,
        ),
        unselectedLabelStyle: AppTextStyles.display(16, context).copyWith(
          letterSpacing: 0.08 * 16,
        ),
        labelColor: colors.text,
        unselectedLabelColor: colors.text3,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            height: 44,
            child: Text('anchor.detail.tab.chats'.tr().toUpperCase()),
          ),
          Tab(
            height: 44,
            child: Text('anchor.detail.tab.info'.tr().toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(AnchorDetailModel detail) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      children: [
        // Avatar + name row
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
                  placeholder: (context, url) => Skeletonizer(
                    enabled: true,
                    child: ColoredBox(color: colors.surface2),
                  ),
                  errorBuilder: (context, url, error) =>
                      ColoredBox(color: colors.surface2),
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
                    style: AppTextStyles.display(18, context)
                        .copyWith(color: colors.text),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: colors.accentEcho,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${detail.collect}',
                        style: AppTextStyles.mono(11)
                            .copyWith(color: colors.text2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (detail.isLive == 1) const _LivePulseBadge(),
          ],
        ),
        const SizedBox(height: 20),
        Divider(height: 0, color: colors.lineStrong),
        const SizedBox(height: 18),
        _InfoRow(
          label: 'anchor.detail.info.title'.tr(),
          value: detail.title,
        ),
        const SizedBox(height: 16),
        _InfoRow(
          label: 'anchor.detail.info.followers'.tr(),
          value: '${detail.collect}',
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

class _LivePulseBadgeState extends State<_LivePulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
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
      decoration: BoxDecoration(
        color: colors.live,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF0E0E0E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'anchor.detail.live'.tr(),
            style: AppTextStyles.display(10, context).copyWith(
              color: const Color(0xFF0E0E0E),
              letterSpacing: 0.12 * 10,
              height: 1,
            ),
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
          Icon(Icons.person_outline_outlined, color: colors.text, size: 11),
          const SizedBox(width: 4),
          Text(
            _format(count),
            style: AppTextStyles.mono(11).copyWith(color: colors.text),
          ),
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
        // Avatar
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
              placeholder: (context, url) => Skeletonizer(
                enabled: true,
                child: ColoredBox(color: colors.surface2),
              ),
              errorBuilder: (context, url, error) =>
                  ColoredBox(color: colors.surface2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Name + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      detail.nickname.toUpperCase(),
                      style: AppTextStyles.display(17, context)
                          .copyWith(color: colors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                detail.title.toUpperCase(),
                style: AppTextStyles.mono(10).copyWith(
                  color: colors.text2,
                  letterSpacing: 1.4,
                ),
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
          Text(
            name,
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
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
          style: AppTextStyles.mono(10).copyWith(
            color: colors.text3,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(color: colors.text),
        ),
      ],
    );
  }
}
