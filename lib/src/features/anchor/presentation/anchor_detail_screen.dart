import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/shared_widgets/diagonal_split_banner.dart';
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
    _onVideoTap(); // reset the hide timer after interaction
  }

  void _openFullscreen() {
    if (_videoController == null || !_videoInitialized) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AnchorVideoFullscreenPage(controller: _videoController!),
      ),
    );
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
        if (_videoController == null && detail.m3u8Url != null && detail.m3u8Url!.isNotEmpty) {
          _initVideoPlayer(detail.m3u8Url!);
        }
      });
    });

    final detailAsync = ref.watch(anchorDetailProvider(widget.anchorId));

    final bannerAsync = ref.watch(bannerProvider);

    return Scaffold(
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

  Widget _buildVideoSection(AsyncValue<AnchorDetailModel> detailAsync) {
    return GestureDetector(
      onTap: _onVideoTap,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: detailAsync.when(
              loading: () => Container(
                color: Colors.grey.shade900,
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              error: (_, _) => Container(color: Colors.grey.shade900),
              data: (detail) => _buildVideoPlayer(detail),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          if (detailAsync.valueOrNull?.isLive == 1)
            Positioned(top: 12, right: 12, child: _LiveBadge()),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(AnchorDetailModel detail) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: video when ready, cover image otherwise
        if (_videoInitialized && _videoController != null)
          VideoPlayer(_videoController!)
        else
          CachedNetworkImage(
            imageUrl: detail.cover,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade700,
              child: const ColoredBox(color: Colors.grey),
            ),
            errorBuilder: (context, url, error) => ColoredBox(color: Colors.grey.shade900),
          ),

        // Initializing spinner
        if (_videoController != null && !_videoInitialized && !_videoError)
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        // Buffering overlay during playback
        if (_videoInitialized && _isBuffering)
          Container(
            color: Colors.black38,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'anchor.detail.video.buffering'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        // Error overlay with retry
        if (_videoError)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'anchor.detail.video.error'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _retryVideo,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('anchor.detail.video.retry'.tr()),
                  ),
                ],
              ),
            ),
          ),

        // Play/pause button (tap-to-show, auto-hides)
        // if (_videoInitialized && !_videoError && _showControls)
        //   Center(
        //     child: GestureDetector(
        //       onTap: _togglePlayPause,
        //       child: Container(
        //         decoration: const BoxDecoration(
        //           color: Colors.black45,
        //           shape: BoxShape.circle,
        //         ),
        //         padding: const EdgeInsets.all(10),
        //         child: Icon(
        //           _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //           color: Colors.white,
        //           size: 36,
        //         ),
        //       ),
        //     ),
        //   ),

        // Fullscreen button (tap-to-show, auto-hides)
        if (_videoInitialized && !_videoError)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.maxFinite,
                  color: Colors.black54,
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: _openFullscreen,
                    icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 28),
                  ),
                ),
              ),
            ),
          ),

        // Offline overlay
        if (!_videoError && (detail.isLive == 0 || detail.m3u8Url == null))
          Container(
            color: Colors.black54,
            child: Center(
              child: Text(
                'anchor.detail.offline'.tr(),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBelowSection(
    AsyncValue<AnchorDetailModel> detailAsync,
    AsyncValue<BannerModel> bannerAsync,
  ) {
    return detailAsync.when(
      loading: () => Center(
        child: Text('anchor.detail.loading'.tr(), style: TextStyle(color: context.appTheme.greyText)),
      ),
      error: (_, _) => Center(
        child: Text(
          'anchor.detail.error.load_failed'.tr(),
          style: TextStyle(color: context.appTheme.greyText),
        ),
      ),
      data: (detail) => Column(
        children: [
          if (detail.notice.isNotEmpty)
            DiagonalSplitBanner(
              leftColor: Colors.amber,
              rightColor: Colors.yellow,
              cutWidth: 10,
              height: 20,
              leftFlex: 1,
              rightFlex: 4,
              leftChild: Text(
                'anchor.detail.info.notice_banner_label'.tr(),
                style: context.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
              rightChild: Marquee(
                text: detail.notice,
                style: context.textTheme.bodySmall?.copyWith(color: Colors.black87),
                scrollAxis: Axis.horizontal,
                blankSpace: 30,
                velocity: 50,
              ),
            ),
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

  Widget _buildRefAppBanner(AsyncValue<BannerModel> bannerAsync) {
    return bannerAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (banner) {
        final apps = banner.refApp;
        if (apps.length == 2) {
          return DiagonalSplitBanner(
            leftColor: Color(0xff389628),
            rightColor: Color(0xffE9225C),
            cutWidth: 20,
            height: 60,
            leftChild: _RefAppButton(icon: apps[0].icon, name: apps[0].name, url: apps[0].url),
            rightChild: _RefAppButton(icon: apps[1].icon, name: apps[1].name, url: apps[1].url),
          );
        } else if (apps.length == 1) {
          return Container(
            height: 60,
            color: Colors.amberAccent,
            child: Center(
              child: _RefAppButton(icon: apps[0].icon, name: apps[0].name, url: apps[0].url),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(text: 'anchor.detail.tab.chats'.tr()),
        Tab(text: 'anchor.detail.tab.info'.tr()),
      ],
    );
  }

  Widget _buildInfoTab(AnchorDetailModel detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnchorInfoHeader(detail: detail),
        const SizedBox(height: 20),
        Divider(height: 0, color: context.appTheme.grey_3),
        const SizedBox(height: 16),
        _InfoRow(label: 'anchor.detail.info.title'.tr(), value: detail.title),
        const SizedBox(height: 16),
        _InfoRow(label: 'anchor.detail.info.followers'.tr(), value: '${detail.collect}'),
        // if (detail.matchId.isNotEmpty) ...[
        //   const SizedBox(height: 16),
        //   _InfoRow(label: 'anchor.detail.info.match_id'.tr(), value: detail.matchId),
        // ],
        // const SizedBox(height: 16),
        // _InfoRow(label: 'anchor.detail.info.updated'.tr(), value: detail.updated),
      ],
    );
  }
}

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
        spacing: 10,
        children: [
          CachedNetworkImage(imageUrl: icon, height: 35),
          Text(name, style: context.textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
      child: Text(
        'anchor.detail.live'.tr(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

class _AnchorInfoHeader extends StatelessWidget {
  const _AnchorInfoHeader({required this.detail});

  final AnchorDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1)),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: detail.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: AppTheme.of(context).shimmerBase,
                highlightColor: AppTheme.of(context).shimmerHighlight,
                child: const ColoredBox(color: Colors.grey),
              ),
              errorWidget: (context, url, error) => ColoredBox(color: context.appTheme.grey_3),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text('${detail.collect}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        if (detail.isLive == 1) _LiveBadge(),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelMedium?.copyWith(color: context.appTheme.greyText)),
        const SizedBox(height: 4),
        Text(value, style: context.textTheme.bodyMedium),
      ],
    );
  }
}
