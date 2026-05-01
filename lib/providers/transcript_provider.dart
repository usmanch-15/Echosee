import 'package:flutter/material.dart';
import 'package:echosee/data/models/transcript_model.dart';
import 'package:echosee/data/repositories/transcript_repository.dart';
import 'package:echosee/data/repositories/supabase_transcript_repository.dart';
import 'package:echosee/data/repositories/translation_repository.dart';

class TranscriptProvider with ChangeNotifier {
  final TranscriptRepository _repository;
  final TranslationRepository _translationRepository;
  List<Transcript> _transcripts = [];
  bool _isLoading = false;
  String? _error;

  List<Transcript> get transcripts => _transcripts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TranscriptProvider({TranscriptRepository? repository, TranslationRepository? translationRepository}) 
      : _repository = repository ?? SupabaseTranscriptRepository(),
        _translationRepository = translationRepository ?? TranslationRepository();

  Future<void> loadTranscripts({int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transcripts = await _repository.getTranscripts(limit: limit);
    } catch (e) {
      _error = _handleError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTranscript(Transcript transcript) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveTranscript(transcript);
      await loadTranscripts(); // Refresh list
    } catch (e) {
      _error = _handleError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTranscript(String id) async {
    try {
      await _repository.deleteTranscript(id);
      _transcripts.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleStar(String id) async {
    try {
      final index = _transcripts.indexWhere((t) => t.id == id);
      if (index != -1) {
        final transcript = _transcripts[index];
        final updatedTranscript = transcript.copyWith(isStarred: !transcript.isStarred);
        
        // Optimistic update
        _transcripts[index] = updatedTranscript;
        notifyListeners();

        await _repository.saveTranscript(updatedTranscript);
      }
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> translateTranscript(String id, String targetLanguage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _transcripts.indexWhere((t) => t.id == id);
      if (index == -1) return;

      final transcript = _transcripts[index];
      final translatedText = await _translationRepository.translateText(transcript.content, targetLanguage);
      
      await _translationRepository.saveTranslation(id, translatedText, targetLanguage);
      
      // Update local state
      _transcripts[index] = transcript.copyWith(
        translatedContent: translatedText,
        translatedLanguage: targetLanguage,
        hasTranslation: true,
      );
    } catch (e) {
      _error = _handleError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSpeakerName(String transcriptId, int speakerId, String name) async {
    try {
      final index = _transcripts.indexWhere((t) => t.id == transcriptId);
      if (index == -1) return;

      final transcript = _transcripts[index];
      final updatedSegments = transcript.speakerSegments.map((segment) {
        if (segment.speakerId == speakerId) {
          return segment.copyWith(speakerName: name);
        }
        return segment;
      }).toList();

      final updatedTranscript = transcript.copyWith(speakerSegments: updatedSegments);
      
      // Save to DB
      await _repository.saveTranscript(updatedTranscript);
      
      // Update local state
      _transcripts[index] = updatedTranscript;
      notifyListeners();
    } catch (e) {
      _error = _handleError(e);
      notifyListeners();
      rethrow;
    }
  }

  String _handleError(dynamic e) {
    final errorString = e.toString();
    if (errorString.contains('SocketException') || 
        errorString.contains('Network') || 
        errorString.contains('failed to connect')) {
      return 'No internet connection. Please check your network.';
    }
    if (errorString.contains('auth/invalid-email')) return 'Invalid email address.';
    if (errorString.contains('auth/user-disabled')) return 'User account disabled.';
    if (errorString.contains('auth/user-not-found')) return 'User not found.';
    if (errorString.contains('auth/wrong-password')) return 'Incorrect password.';
    
    return errorString;
  }
}
