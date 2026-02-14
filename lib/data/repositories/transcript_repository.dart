// lib/data/repositories/transcript_repository.dart
import 'dart:async';
import 'package:echo_see_companion/data/models/transcript_model.dart';

abstract class TranscriptRepository {
  Future<List<Transcript>> getTranscripts({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
    String? filter,
    String? sortBy,
  });

  Future<Transcript> getTranscript(String id);
  Future<Transcript> saveTranscript(Transcript transcript);
  Future<void> updateTranscript(Transcript transcript);
  Future<void> deleteTranscript(String id);
  Future<void> deleteAllTranscripts();
  Future<List<Transcript>> searchTranscripts(String query);
  Future<int> getTranscriptCount();
  Future<double> getStorageUsed();
  Future<void> exportTranscripts(String format);
  Future<void> starTranscript(String id, bool starred);
  Future<List<Transcript>> getStarredTranscripts();
}

class LocalTranscriptRepository implements TranscriptRepository {
  final List<Transcript> _transcripts = [];
  static const int _maxFreeTranscripts = 5;

  @override
  Future<List<Transcript>> getTranscripts({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
    String? filter,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay

    List<Transcript> filtered = List.from(_transcripts);

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
      t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.content.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply filters
    if (filter == 'starred') {
      filtered = filtered.where((t) => t.isStarred).toList();
    } else if (filter == 'translated') {
      filtered = filtered.where((t) => t.hasTranslation).toList();
    } else if (filter == 'today') {
      final today = DateTime.now();
      filtered = filtered.where((t) =>
      t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day
      ).toList();
    }

    // Apply sorting
    if (sortBy == 'name') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'date') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortBy == 'duration') {
      filtered.sort((a, b) => b.duration.compareTo(a.duration));
    }

    // Apply pagination
    final start = offset;
    final end = start + limit;
    return filtered.sublist(
      start.clamp(0, filtered.length),
      end.clamp(0, filtered.length),
    );
  }

  @override
  Future<Transcript> getTranscript(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final transcript = _transcripts.firstWhere((t) => t.id == id);
    return transcript;
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if we need to delete oldest (for free users)
    if (_transcripts.length >= _maxFreeTranscripts) {
      // Find and remove oldest transcript
      _transcripts.sort((a, b) => a.date.compareTo(b.date));
      _transcripts.removeAt(0);
    }

    _transcripts.add(transcript);
    return transcript;
  }

  @override
  Future<void> updateTranscript(Transcript transcript) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transcripts.indexWhere((t) => t.id == transcript.id);
    if (index != -1) {
      _transcripts[index] = transcript;
    }
  }

  @override
  Future<void> deleteTranscript(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transcripts.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> deleteAllTranscripts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _transcripts.clear();
  }

  @override
  Future<List<Transcript>> searchTranscripts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transcripts.where((t) =>
    t.title.toLowerCase().contains(query.toLowerCase()) ||
        t.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<int> getTranscriptCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _transcripts.length;
  }

  @override
  Future<double> getStorageUsed() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate storage calculation
    final baseSize = _transcripts.length * 0.1; // 0.1 MB per transcript
    return baseSize;
  }

  @override
  Future<void> exportTranscripts(String format) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate export
    print('Exporting ${_transcripts.length} transcripts as $format');
  }

  @override
  Future<void> starTranscript(String id, bool starred) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transcripts.indexWhere((t) => t.id == id);
    if (index != -1) {
      final transcript = _transcripts[index];
      _transcripts[index] = transcript.copyWith(isStarred: starred);
    }
  }

  @override
  Future<List<Transcript>> getStarredTranscripts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transcripts.where((t) => t.isStarred).toList();
  }
}