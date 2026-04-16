import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_video_fullscreen_page.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:sports_app/src/features/video/presentation/providers/video_providers.dart';
import 'package:sports_app/src/features/video/presentation/widgets/home_video_list.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends ConsumerStatefulWidget {
  const VideoDetailScreen({
    super.key,
    required this.videoId,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  final int videoId;
  final int currentPage;
  final int lastPage;

  @override
  ConsumerState<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends ConsumerState<VideoDetailScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;
  bool _isBuffering = false;
  bool _showControls = false;
  Timer? _controlsTimer;
  late int _currentVideoId;
  late final int _randomPage;
  final ScrollController _scrollController = ScrollController();

  String get _locale => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  @override
  void initState() {
    super.initState();
    _currentVideoId = widget.videoId;
    _randomPage = _pickRandomPage(widget.currentPage, widget.lastPage);
  }

  int _pickRandomPage(int currentPage, int lastPage) {
    final minPage = math.max(1, currentPage - 5);
    final maxPage = math.min(math.max(1, lastPage), currentPage + 5);
    final candidates = [
      for (var p = minPage; p <= maxPage; p++)
        if (p != currentPage) p,
    ];
    if (candidates.isEmpty) return currentPage;
    return candidates[math.Random().nextInt(candidates.length)];
  }

  void _switchVideo(int newVideoId) {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    setState(() {
      _controller = null;
      _initialized = false;
      _error = false;
      _isBuffering = false;
      _showControls = false;
      _currentVideoId = newVideoId;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _initPlayer(String url) async {
    if (_controller != null) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller!.addListener(_onUpdate);
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        _controller!.play();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _onUpdate() {
    if (!mounted) return;
    final c = _controller;
    if (c == null) return;
    final buffering = c.value.isBuffering;
    if (buffering != _isBuffering) setState(() => _isBuffering = buffering);
    if (c.value.hasError && !_error) setState(() => _error = true);
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_initialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
    _onTap();
  }

  void _openFullscreen() {
    if (_controller == null || !_initialized) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AnchorVideoFullscreenPage(controller: _controller!),
      ),
    );
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale;
    final asyncDetail = ref.watch(videoDetailProvider(_currentVideoId, locale));

    ref.listen(videoDetailProvider(_currentVideoId, locale), (_, next) {
      next.whenData((detail) {
        final url = detail.albbHlsUrl ?? detail.path;
        if (_controller == null && url.isNotEmpty) {
          _initPlayer(url);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'video.detail_title'.tr(),
          style: context.textTheme.titleSmall,
        ),
      ),
      body: asyncDetail.when(
        loading: () => Column(
          children: [
            _buildVideoArea(),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (e, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.showErrorDialog(
                title: 'video.load_error'.tr(),
                error: e,
              );
            }
          });
          return Column(
            children: [
              _buildVideoArea(),
              Expanded(
                child: Center(
                  child: Text(
                    'home.error.load_failed'.tr(),
                  ),
                ),
              ),
            ],
          );
        },
        data: (detail) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoArea(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('yyyy-MM-dd hh:mm').format(DateTime.parse(detail.createTime)),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    HomeSectionTitle(title: 'video.more_videos'.tr(), icon: 'assets/images/news.png'),
                    HomeVideoList(
                      locale: _locale,
                      page: _randomPage,
                      onVideoTap: (video) => _switchVideo(video.id),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: _onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_initialized && _controller != null)
              VideoPlayer(_controller!)
            else
              Container(color: Colors.black),
            if (!_initialized && !_error)
              const CircularProgressIndicator(color: Colors.white),
            if (_error)
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            if (_initialized && _showControls)
              _ControlsOverlay(
                isPlaying: _controller?.value.isPlaying ?? false,
                onPlayPause: _togglePlay,
                onFullscreen: _openFullscreen,
                position: _controller?.value.position ?? Duration.zero,
                duration: _controller?.value.duration ?? Duration.zero,
                onSeek: (pos) => _controller?.seekTo(pos),
              ),
            if (_isBuffering && _initialized)
              const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onFullscreen,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onFullscreen;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: Colors.black38,
      child: Stack(
        children: [
          Center(
            child: IconButton(
              iconSize: 56,
              color: Colors.white,
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
              onPressed: onPlayPause,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (v) => onSeek(
                        Duration(milliseconds: (v * duration.inMilliseconds).round()),
                      ),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: onFullscreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
