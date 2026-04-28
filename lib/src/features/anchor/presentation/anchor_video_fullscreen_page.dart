import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class AnchorVideoFullscreenPage extends StatefulWidget {
  const AnchorVideoFullscreenPage({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<AnchorVideoFullscreenPage> createState() =>
      _AnchorVideoFullscreenPageState();
}

class _AnchorVideoFullscreenPageState
    extends State<AnchorVideoFullscreenPage> {
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    widget.controller.addListener(_onControllerUpdate);
    _scheduleHide();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTap() {
    setState(() => _showControls = true);
    _scheduleHide();
  }

  void _togglePlayPause() {
    final controller = widget.controller;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
    _scheduleHide();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _handleExit() async {
    widget.controller.pause(); // optional but nicer UX
    setState(() => _showControls = false);

    await Future.delayed(const Duration(milliseconds: 150));
    await _exitFullscreen();

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio,
                // controller.value.aspectRatio == 0
                //     ? 16 / 9
                //     : controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  color: Colors.black45,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: _handleExit,
                          ),
                        ),
                        const Spacer(),

                        // Play / Pause
                        // Center(
                        //   child: GestureDetector(
                        //     onTap: _togglePlayPause,
                        //     child: Container(
                        //       decoration: const BoxDecoration(
                        //         color: Colors.black54,
                        //         shape: BoxShape.circle,
                        //       ),
                        //       padding: const EdgeInsets.all(14),
                        //       child: Icon(
                        //         controller.value.isPlaying
                        //             ? Icons.pause
                        //             : Icons.play_arrow,
                        //         color: Colors.white,
                        //         size: 40,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        const Spacer(),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _handleExit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}