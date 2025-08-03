import 'package:just_audio/just_audio.dart';

class AudioController {
  final AudioPlayer _bgPlayer = AudioPlayer(); // background music
  final AudioPlayer _fxPlayer = AudioPlayer(); // segment audio

  Future<void> playBackground(String assetPath) async {
    try {
      await _bgPlayer.setAudioSource(AudioSource.asset(assetPath));
      await _bgPlayer.setLoopMode(LoopMode.one);
      await _bgPlayer.play();
    } catch (e) {
      print("BG audio error: $e");
    }
  }

  Future<void> stopBackground() async => await _bgPlayer.stop();

  Future<void> playSegment(String assetPath) async {
    try {
      await _fxPlayer.setAudioSource(AudioSource.asset(assetPath));
      await _fxPlayer.setLoopMode(LoopMode.off);
      await _fxPlayer.play();
    } catch (e) {
      print("FX audio error: $e");
    }
  }

  Future<void> pauseSegment() async => await _fxPlayer.pause();
  Future<void> resumeSegment() async => await _fxPlayer.play();
  Future<void> stopSegment() async => await _fxPlayer.stop();

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _fxPlayer.dispose();
  }

  bool get isSegmentPlaying => _fxPlayer.playing;
}
