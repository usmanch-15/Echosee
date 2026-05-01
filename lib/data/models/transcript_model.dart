// lib/data/models/transcript_model.dart
class Transcript {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Duration duration;
  final String language;
  final bool hasTranslation;
  final List<SpeakerSegment> speakerSegments;
  final bool isStarred;
  final String? translatedContent;
  final String? translatedLanguage;

  Transcript({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.duration,
    required this.language,
    this.hasTranslation = false,
    required this.speakerSegments,
    this.isStarred = false,
    this.translatedContent,
    this.translatedLanguage,
  });

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration'] ?? 0),
      language: json['language'],
      hasTranslation: json['hasTranslation'] ?? false,
      speakerSegments: (json['speakerSegments'] as List? ?? [])
          .map((segment) => SpeakerSegment.fromJson(segment))
          .toList(),
      isStarred: json['isStarred'] ?? false,
      translatedContent: json['translatedContent'],
      translatedLanguage: json['translatedLanguage'],
    );
  }

  factory Transcript.fromSupabase(Map<String, dynamic> json) {
    return Transcript(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration'] ?? 0),
      language: json['language'],
      hasTranslation: json['has_translation'] ?? false,
      speakerSegments: (json['speaker_segments'] as List? ?? [])
          .map((segment) => SpeakerSegment.fromJson(segment))
          .toList(),
      isStarred: json['is_starred'] ?? false,
      translatedContent: json['translated_content'],
      translatedLanguage: json['translated_language'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
      'language': language,
      'has_translation': hasTranslation,
      'speaker_segments': speakerSegments.map((s) => s.toJson()).toList(),
      'is_starred': isStarred,
      'translated_content': translatedContent,
      'translated_language': translatedLanguage,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
      'language': language,
      'hasTranslation': hasTranslation,
      'speakerSegments': speakerSegments.map((s) => s.toJson()).toList(),
      'isStarred': isStarred,
      'translatedContent': translatedContent,
      'translatedLanguage': translatedLanguage,
    };
  }

  // ADD THIS copyWith METHOD
  Transcript copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    Duration? duration,
    String? language,
    bool? hasTranslation,
    List<SpeakerSegment>? speakerSegments,
    bool? isStarred,
    String? translatedContent,
    String? translatedLanguage,
  }) {
    return Transcript(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      hasTranslation: hasTranslation ?? this.hasTranslation,
      speakerSegments: speakerSegments ?? this.speakerSegments,
      isStarred: isStarred ?? this.isStarred,
      translatedContent: translatedContent ?? this.translatedContent,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
    );
  }

  String get formattedDate {
    if (date.day == DateTime.now().day) {
      return 'Today';
    } else if (date.day == DateTime.now().day - 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class SpeakerSegment {
  final int speakerId;
  final String? speakerName;
  final String text;
  final Duration startTime;
  final Duration endTime;

  SpeakerSegment({
    required this.speakerId,
    this.speakerName,
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory SpeakerSegment.fromJson(Map<String, dynamic> json) {
    return SpeakerSegment(
      speakerId: json['speakerId'],
      speakerName: json['speakerName'],
      text: json['text'],
      startTime: Duration(seconds: json['startTime']),
      endTime: Duration(seconds: json['endTime']),
    );
  }

  factory SpeakerSegment.fromSupabase(Map<String, dynamic> json) {
    return SpeakerSegment(
      speakerId: json['speaker_id'],
      speakerName: json['speaker_name'],
      text: json['text'],
      startTime: Duration(seconds: json['start_time']),
      endTime: Duration(seconds: json['end_time']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'speaker_id': speakerId,
      'speaker_name': speakerName,
      'text': text,
      'start_time': startTime.inSeconds,
      'end_time': endTime.inSeconds,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'speakerId': speakerId,
      'speakerName': speakerName,
      'text': text,
      'startTime': startTime.inSeconds,
      'endTime': endTime.inSeconds,
    };
  }

  // ADD copyWith for SpeakerSegment too
  SpeakerSegment copyWith({
    int? speakerId,
    String? speakerName,
    String? text,
    Duration? startTime,
    Duration? endTime,
  }) {
    return SpeakerSegment(
      speakerId: speakerId ?? this.speakerId,
      speakerName: speakerName ?? this.speakerName,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
