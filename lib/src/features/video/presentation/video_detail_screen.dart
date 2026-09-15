import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/anchor/presentation/anchor_video_fullscreen_page.dart';
import 'package:shenghaotiyu/src/features/home/presentation/widgets/home_section_title.dart';
import 'package:shenghaotiyu/src/features/video/presentation/providers/video_providers.dart';
import 'package:shenghaotiyu/src/features/video/presentation/widgets/home_video_list.dart';
import 'package:video_player/video_player.dart';

/// Picks a page near [currentPage] (within a window of 5) to seed the
/// "more videos" rail with, so it doesn't always show the same neighbours.
int _pickNearbyPage(int currentPage, int lastPage) {
  final minPage = math.max(1, currentPage - 5);
  final maxPage = math.min(math.max(1, lastPage), currentPage + 5);
  final candidates = [
    for (var p = minPage; p <= maxPage; p++)
      if (p != currentPage) p,
  ];
  if (candidates.isEmpty) return currentPage;
  return candidates[math.Random().nextInt(candidates.length)];
}

/// Owns the [VideoPlayerController] lifecycle and exposes playback state as
/// a [ChangeNotifier] so the screen widget doesn't juggle player bookkeeping
/// directly in its own State.
class _PlaybackController extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool initialized = false;
  bool hasError = false;
  bool buffering = false;
  bool controlsVisible = false;
  Timer? _hideControlsTimer;

  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  Duration get position => _controller?.value.position ?? Duration.zero;
  Duration get duration => _controller?.value.duration ?? Duration.zero;

  Future<void> load(String url) async {
    if (_controller != null) return;
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

  void togglePlayback() {
    final controller = _controller;
    if (controller == null || !initialized) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _revealControls();
  }

  void toggleControlsVisible() {
    controlsVisible = !controlsVisible;
    notifyListeners();
    if (controlsVisible) _scheduleAutoHide();
  }

  void _revealControls() {
    controlsVisible = true;
    notifyListeners();
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      controlsVisible = false;
      notifyListeners();
    });
  }

  void seekTo(Duration target) => _controller?.seekTo(target);

  /// Tears down the current player so a new source can be loaded into a
  /// fresh controller (used when the viewer taps a "more videos" suggestion).
  void reset() {
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    _controller = null;
    initialized = false;
    hasError = false;
    buffering = false;
    controlsVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }
}

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
  final _playback = _PlaybackController();
  final _scrollController = ScrollController();
  late int _activeVideoId = widget.videoId;
  late final int _suggestionsPage = _pickNearbyPage(widget.currentPage, widget.lastPage);

  String get _locale => context.localeCode;

  @override
  void initState() {
    super.initState();
    _playback.addListener(_onPlaybackChanged);
  }

  void _onPlaybackChanged() {
    if (mounted) setState(() {});
  }

  void _playSuggestion(int videoId) {
    _playback.reset();
    setState(() => _activeVideoId = videoId);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _openFullscreen() {
    final controller = _playback.controller;
    if (controller == null || !_playback.initialized) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AnchorVideoFullscreenPage(controller: controller),
      ),
    );
  }

  @override
  void dispose() {
    _playback
      ..removeListener(_onPlaybackChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale;
    final asyncDetail = ref.watch(videoDetailProvider(_activeVideoId, locale));

    ref.listen(videoDetailProvider(_activeVideoId, locale), (_, next) {
      next.whenData((detail) {
        final url = detail.albbHlsUrl ?? detail.path;
        if (_playback.controller == null && url.isNotEmpty) {
          _playback.load(url);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text('video.detail_title'.tr(), style: context.textTheme.titleSmall)),
      body: Column(
        children: [
          _PlayerSurface(playback: _playback, onFullscreen: _openFullscreen),
          Expanded(child: _buildBelowPlayer(asyncDetail)),
        ],
      ),
    );
  }

  Widget _buildBelowPlayer(AsyncValue asyncDetail) {
    if (asyncDetail.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (asyncDetail.hasError) {
      final error = asyncDetail.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.showErrorDialog(title: 'video.load_error'.tr(), error: error!);
        }
      });
      return Center(child: Text('home.error.load_failed'.tr()));
    }

    final detail = asyncDetail.requireValue;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VideoInfoCard(title: detail.title, createdAt: detail.createTime),
          HomeSectionTitle(title: 'video.more_videos'.tr(), icon: 'assets/images/news.png'),
          HomeVideoList(
            locale: _locale,
            page: _suggestionsPage,
            onVideoTap: (video) => _playSuggestion(video.id),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _VideoInfoCard extends StatelessWidget {
  const _VideoInfoCard({required this.title, required this.createdAt});

  final String title;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: context.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd hh:mm').format(DateTime.parse(createdAt)),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({required this.playback, required this.onFullscreen});

  final _PlaybackController playback;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: playback.toggleControlsVisible,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (playback.initialized && playback.controller != null)
                VideoPlayer(playback.controller!),
              if (!playback.initialized && !playback.hasError)
                const CircularProgressIndicator(color: Colors.white),
              if (playback.hasError)
                const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              if (playback.buffering && playback.initialized)
                const CircularProgressIndicator(color: Colors.white),
              if (playback.initialized && playback.controlsVisible)
                _PlaybackBar(playback: playback, onFullscreen: onFullscreen),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({required this.playback, required this.onFullscreen});

  final _PlaybackController playback;
  final VoidCallback onFullscreen;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final position = playback.position;
    final duration = playback.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: onFullscreen,
              ),
            ),
            IconButton(
              iconSize: 56,
              color: Colors.white,
              icon: Icon(playback.isPlaying ? Icons.pause_circle : Icons.play_circle),
              onPressed: playback.togglePlayback,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (v) => playback.seekTo(
                          Duration(milliseconds: (v * duration.inMilliseconds).round()),
                        ),
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
