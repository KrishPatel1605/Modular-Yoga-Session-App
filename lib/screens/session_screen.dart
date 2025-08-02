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
  bool isPlaying = false;
  bool hasStarted = false;

  Duration get totalDuration =>
      Duration(seconds: _manager.totalDurationSeconds);

  @override
  void initState() {
    super.initState();
    _manager = SessionManager(widget.session);
  }

  Future<void> _startSession() async {
    setState(() {
      hasStarted = true;
      isPlaying = true;
    });

    _audio.playBackground('assets/audio/background.mp3');
    _startSegment();
    _startProgressTracking();
  }

  void _startSegment() async {
    _clearSegmentTimers();

    final segment = _manager.currentSegment;
    final audioPath =
        'assets/audio/${widget.session.assets.audio[segment.audioRef]}';

    _audio.playSegment(audioPath);
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

      _scriptTimers.add(
        Timer(delay, () {
          if (!mounted || !_manager.isCurrentSegment(segment)) return;
          setState(() {
            _manager.setScriptIndex(i);
          });
        }),
      );
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
      await _audio.resumeSegment();
      _startProgressTracking();
    } else {
      _clearSegmentTimers();
      await _audio.pauseSegment();
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
    if (!hasStarted) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.session.metadata.title)),
        body: Center(
          child: ElevatedButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('Start Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    if (_manager.isSessionComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.self_improvement,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Namaste 🙏',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text('Return Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final script = _manager.currentScript;
    final imgPath =
        'assets/images/${widget.session.assets.images[script.imageRef]}';
    final progress = _elapsed.inSeconds / totalDuration.inSeconds;
    final progressText =
        '${_formatDuration(_elapsed)} / ${_formatDuration(totalDuration)}';

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.metadata.title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Image.asset(imgPath, fit: BoxFit.contain)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                script.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0,right: 24.0,bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      disabledActiveTrackColor: Colors.deepPurple,
                      disabledInactiveTrackColor: Colors.deepPurple.shade100,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: null,
                      min: 0,
                      max: 1,
                    ),
                  ),
                  Text(
                    progressText,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        backgroundColor: Colors.deepPurple,
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
