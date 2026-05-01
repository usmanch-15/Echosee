// lib/data/repositories/translation_repository.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class TranslationRepository {
  SupabaseClient get _client => Supabase.instance.client;

  // Simple Urdu translation mapping for common phrases
  static const Map<String, String> _urduTranslations = {
    // Greetings
    'hello': 'ہیلو',
    'good morning': 'صبح بخیر',
    'good afternoon': 'دوپہر بخیر',
    'good evening': 'شام بخیر',
    'how are you': 'آپ کیسے ہیں',
    'thank you': 'شکریہ',
    'welcome': 'خوش آمدید',
    
    // Common phrases
    'yes': 'ہاں',
    'no': 'نہیں',
    'okay': 'ٹھیک ہے',
    'please': 'براہ کرم',
    'sorry': 'معافی چاہتا ہوں',
    'excuse me': 'معاف کیجیے',
    
    // Listening/Recording
    'listening': 'سن رہا ہوں',
    'recording': 'ریکارڈ ہو رہا ہے',
    'stopped': 'رک گیا',
    'processing': 'پروسیس ہو رہا ہے',
    
    // Time
    'today': 'آج',
    'yesterday': 'کل',
    'tomorrow': 'کل',
    'this week': 'اس ہفتے',
    'this month': 'اس مہینے',
  };

  Future<String> translateText(String text, String targetLanguage) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerText = text.toLowerCase();

    if (targetLanguage == 'UR' || targetLanguage == 'urdu') {
      // Try direct translation from map
      if (_urduTranslations.containsKey(lowerText)) {
        return _urduTranslations[lowerText]!;
      }

      // If not found, return text as-is with note
      // In production, this would call a translation API like Google Translate
      return text; // For now, return original text
    } else if (targetLanguage == 'EN' || targetLanguage == 'english') {
      return text; // Already in English
    } else if (targetLanguage == 'ES') {
      return 'Traducción: $text (en Español)';
    } else if (targetLanguage == 'FR') {
      return 'Traduction: $text (en Français)';
    } else {
      return 'Translated ($targetLanguage): $text';
    }
  }

  // Translate entire transcript
  Future<String> translateTranscript(String content, String targetLanguage) async {
    final sentences = content.split('.');
    final translatedSentences = <String>[];

    for (final sentence in sentences) {
      if (sentence.trim().isEmpty) continue;
      final translated = await translateText(sentence.trim(), targetLanguage);
      translatedSentences.add(translated);
    }

    return translatedSentences.join('. ') + (translatedSentences.isNotEmpty ? '.' : '');
  }

  Future<void> saveTranslation(
    String transcriptId,
    String content,
    String language,
  ) async {
    try {
      await _client.from('transcripts').update({
        'translated_content': content,
        'translated_language': language,
        'has_translation': true,
      }).eq('id', transcriptId);
    } catch (e) {
      // Handle error - in production, log to analytics
      throw Exception('Failed to save translation: $e');
    }
  }

  // Get supported languages
  List<String> getSupportedLanguages() => ['EN', 'UR', 'ES', 'FR'];

  // Get language name
  String getLanguageName(String code) {
    const languageMap = {
      'EN': 'English',
      'UR': 'اردو (Urdu)',
      'ES': 'Español',
      'FR': 'Français',
    };
    return languageMap[code.toUpperCase()] ?? code;
  }
}
