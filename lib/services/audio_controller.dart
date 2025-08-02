// services/audio_controller.dart
import 'package:just_audio/just_audio.dart';

class AudioController {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      print("Audio error: $e");
    }
  }

  Future<void> pause() async => await _player.pause();
  Future<void> resume() async => await _player.play();
  Future<void> stop() async => await _player.stop();
  Future<void> dispose() async => await _player.dispose();

  Stream<Duration> get positionStream => _player.positionStream;
  bool get isPlaying => _player.playing;
}
