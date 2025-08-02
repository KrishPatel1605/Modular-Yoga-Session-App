// models/yoga_session.dart
class YogaSession {
  final Metadata metadata;
  final Assets assets;
  final List<YogaSegment> sequence;

  YogaSession({
    required this.metadata,
    required this.assets,
    required this.sequence,
  });

  factory YogaSession.fromJson(Map<String, dynamic> json) {
    return YogaSession(
      metadata: Metadata.fromJson(json['metadata']),
      assets: Assets.fromJson(json['assets']),
      sequence:
          (json['sequence'] as List)
              .map((e) => YogaSegment.fromJson(e))
              .toList(),
    );
  }
}

class Metadata {
  final String id, title, category, tempo;
  final int defaultLoopCount;

  Metadata({
    required this.id,
    required this.title,
    required this.category,
    required this.tempo,
    required this.defaultLoopCount,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    id: json['id'],
    title: json['title'],
    category: json['category'],
    tempo: json['tempo'],
    defaultLoopCount: json['defaultLoopCount'],
  );
}

class Assets {
  final Map<String, String> images;
  final Map<String, String> audio;

  Assets({required this.images, required this.audio});

  factory Assets.fromJson(Map<String, dynamic> json) => Assets(
    images: Map<String, String>.from(json['images']),
    audio: Map<String, String>.from(json['audio']),
  );
}

class YogaSegment {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final int iterations;
  final List<ScriptLine> script;

  YogaSegment({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    required this.iterations,
    required this.script,
  });

  factory YogaSegment.fromJson(Map<String, dynamic> json) => YogaSegment(
    type: json['type'],
    name: json['name'],
    audioRef: json['audioRef'],
    durationSec: json['durationSec'],
    iterations:
        int.tryParse(
          json['iterations'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0,
    script:
        (json['script'] as List).map((e) => ScriptLine.fromJson(e)).toList(),
  );
}

class ScriptLine {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  ScriptLine({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory ScriptLine.fromJson(Map<String, dynamic> json) => ScriptLine(
    text: json['text'],
    startSec: json['startSec'],
    endSec: json['endSec'],
    imageRef: json['imageRef'],
  );
}
