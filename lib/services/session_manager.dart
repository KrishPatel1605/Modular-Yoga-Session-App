import '../models/yoga_session.dart';

class SessionManager {
  final YogaSession session;
  int segmentIndex = 0;
  int scriptIndex = 0;
  int currentLoop = 0;

  SessionManager(this.session);

  YogaSegment get currentSegment => session.sequence[segmentIndex];
  ScriptLine get currentScript => currentSegment.script[scriptIndex];

  bool get isLastSegment => segmentIndex >= session.sequence.length - 1;
  bool get isLastScript => scriptIndex >= currentSegment.script.length - 1;

  void nextScript() {
    if (isLastScript) {
      if (currentSegment.type == 'loop' && currentLoop < currentSegment.iterations - 1) {
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
}
