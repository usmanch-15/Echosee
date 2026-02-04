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
  });

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration']),
      language: json['language'],
      hasTranslation: json['hasTranslation'],
      speakerSegments: (json['speakerSegments'] as List)
          .map((segment) => SpeakerSegment.fromJson(segment))
          .toList(),
      isStarred: json['isStarred'],
    );
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
  final String text;
  final Duration startTime;
  final Duration endTime;

  SpeakerSegment({
    required this.speakerId,
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory SpeakerSegment.fromJson(Map<String, dynamic> json) {
    return SpeakerSegment(
      speakerId: json['speakerId'],
      text: json['text'],
      startTime: Duration(seconds: json['startTime']),
      endTime: Duration(seconds: json['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speakerId': speakerId,
      'text': text,
      'startTime': startTime.inSeconds,
      'endTime': endTime.inSeconds,
    };
  }

  // ADD copyWith for SpeakerSegment too
  SpeakerSegment copyWith({
    int? speakerId,
    String? text,
    Duration? startTime,
    Duration? endTime,
  }) {
    return SpeakerSegment(
      speakerId: speakerId ?? this.speakerId,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}