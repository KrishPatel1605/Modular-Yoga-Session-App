import 'dart:async';
import 'package:flutter/material.dart';
import '../models/yoga_session.dart';
import '../services/audio_controller.dart';
import '../services/session_manager.dart';

class SessionScreen extends StatefulWidget {
  final YogaSession session;
  late final int defaultLoopCount;
  SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SessionManager _manager;
  final AudioController _audio = AudioController();
  Timer? _segmentTimer;
  final List<Timer> _scriptTimers = [];
  Timer? _progressTimer;
  Duration _elapsed = Duration.zero;
  bool isPlaying = true;

  Duration get totalDuration => Duration(seconds: _manager.totalDurationSeconds);

  @override
  void initState() {
    super.initState();
    _manager = SessionManager(widget.session);
    _startSegment();
    _startProgressTracking();
  }

  void _startSegment() async {
    _clearSegmentTimers();

    final segment = _manager.currentSegment;
    final audioPath = 'assets/audio/${widget.session.assets.audio[segment.audioRef]}';

    // Play the full segment audio once
    await _audio.play(audioPath);

    _scheduleScriptUpdates(segment);

    final segmentDuration = Duration(seconds: segment.durationSec);
    _segmentTimer = Timer(segmentDuration, () {
      if (mounted) {
        setState(() {
          _manager.nextScript();
        });
        if (!_manager.isSessionComplete) {
          _startSegment();
        }
      }
    });
  }

  void _scheduleScriptUpdates(YogaSegment segment) {
    final scriptLines = segment.script;

    for (int i = 0; i < scriptLines.length; i++) {
      final line = scriptLines[i];
      final delay = Duration(seconds: line.startSec);

      _scriptTimers.add(Timer(delay, () {
        if (!mounted || !_manager.isCurrentSegment(segment)) return;
        setState(() {
          _manager.setScriptIndex(i);
        });
      }));
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted && isPlaying && !_manager.isSessionComplete) {
        setState(() {
          _elapsed += const Duration(milliseconds: 500);
        });
      }
    });
  }

  void _togglePlay() async {
    setState(() => isPlaying = !isPlaying);
    if (isPlaying) {
      _startSegment();
    } else {
      _clearSegmentTimers();
      await _audio.pause();
    }
  }

  void _clearSegmentTimers() {
    _segmentTimer?.cancel();
    for (final timer in _scriptTimers) {
      timer.cancel();
    }
    _scriptTimers.clear();
  }

  @override
  void dispose() {
    _clearSegmentTimers();
    _progressTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manager.isSessionComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Complete')),
        body: const Center(child: Text('Namaste 🙏', style: TextStyle(fontSize: 24))),
      );
    }

    final script = _manager.currentScript;
    final imgPath = 'assets/images/${widget.session.assets.images[script.imageRef]}';

    final progress = _elapsed.inSeconds / totalDuration.inSeconds;
    final progressText = _formatDuration(_elapsed) + ' / ' + _formatDuration(totalDuration);

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.metadata.title)),
      body: Column(
        children: [
          Expanded(child: Image.asset(imgPath, fit: BoxFit.contain)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(script.text, style: const TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: null,
                  min: 0,
                  max: 1,
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.deepPurple.shade100,
                ),
                Text(progressText),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
