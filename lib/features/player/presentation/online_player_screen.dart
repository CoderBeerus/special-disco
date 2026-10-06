import 'dart:async';

import 'package:aniweb/core/constants/app_constants.dart';
import 'package:aniweb/core/extensions/duration_extensions.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class OnlinePlayerScreen extends StatefulWidget {
  const OnlinePlayerScreen({
    required this.url,
    required this.title,
    super.key,
  });

  final String url;
  final String title;

  @override
  State<OnlinePlayerScreen> createState() => _OnlinePlayerScreenState();
}

class _OnlinePlayerScreenState extends State<OnlinePlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  Timer? _hideTimer;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _player.open(Media(widget.url));
    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _controlsVisible = !_controlsVisible),
        onDoubleTapDown: (details) {
          final half = MediaQuery.sizeOf(context).width / 2;
          final seek = details.localPosition.dx < half ? -10 : 10;
          final now = _player.state.position;
          _player.seek(now + Duration(seconds: seek));
          _resetHideTimer();
        },
        child: Stack(
          children: [
            Center(child: Video(controller: _videoController)),
            if (_controlsVisible) _Controls(player: _player, title: widget.title),
          ],
        ),
      ),
    );
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(AppConstants.controlsAutoHide, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player, required this.title});

  final Player player;
  final String title;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (context, positionSnap) {
        final position = positionSnap.data ?? Duration.zero;
        final duration = player.state.duration;
        final maxMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
        return SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => player.seek(position - const Duration(seconds: 10)),
                    color: Colors.white,
                    icon: const Icon(Icons.replay_10),
                  ),
                  StreamBuilder<bool>(
                    stream: player.stream.playing,
                    builder: (context, playingSnap) {
                      final playing = playingSnap.data ?? false;
                      return IconButton(
                        onPressed: () => playing ? player.pause() : player.play(),
                        color: Colors.white,
                        iconSize: 42,
                        icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => player.seek(position + const Duration(seconds: 10)),
                    color: Colors.white,
                    icon: const Icon(Icons.forward_10),
                  ),
                ],
              ),
              Slider(
                value: position.inMilliseconds.clamp(0, maxMs).toDouble(),
                min: 0,
                max: maxMs.toDouble(),
                onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      position.toPlayerLabel(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      duration.toPlayerLabel(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
