import '../models/yoga_session.dart';

class SessionManager {
  final YogaSession session;
  int segmentIndex = 0;
  int scriptIndex = 0;
  int currentLoop = 0;
  late int defaultLoopCount;

  SessionManager(this.session) {
    defaultLoopCount = session.metadata.defaultLoopCount;
  }

  YogaSegment get currentSegment => session.sequence[segmentIndex];
  ScriptLine get currentScript => currentSegment.script[scriptIndex];

  bool get isLastSegment => segmentIndex >= session.sequence.length - 1;
  bool get isLastScript => scriptIndex >= currentSegment.script.length - 1;

  void nextScript() {
    if (isLastScript) {
      final loopLimit = currentSegment.iterations > 0 ? currentSegment.iterations : defaultLoopCount;
    if (currentSegment.type == 'loop' && currentLoop < loopLimit - 1) {
        currentLoop++;
        scriptIndex = 0;
      } else {
        currentLoop = 0;
        nextSegment();
      }
    } else {
      scriptIndex++;
    }
  }

  void nextSegment() {
    if (!isLastSegment) {
      segmentIndex++;
      scriptIndex = 0;
    } else {
      segmentIndex++;
    }
  }

  void setScriptIndex(int index) {
    if (index >= 0 && index < currentSegment.script.length) {
      scriptIndex = index;
    }
  }

  bool get isSessionComplete => segmentIndex >= session.sequence.length;

  bool isCurrentSegment(YogaSegment segment) {
    return session.sequence[segmentIndex] == segment;
  }

  int get totalDurationSeconds {
    int total = 0;
    for (final segment in session.sequence) {
      final iterations = segment.type == 'loop' ? (segment.iterations > 0 ? segment.iterations : defaultLoopCount) : 1;
      total += segment.durationSec * iterations;
    }
    return total;
  }
}
