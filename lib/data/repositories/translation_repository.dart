// lib/data/repositories/translation_repository.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class TranslationRepository {
  final _client = Supabase.instance.client;

  Future<String> translateText(String text, String targetLanguage) async {
    // Mock API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple mock translation logic
    if (targetLanguage == 'ES') {
      return 'Traducción: $text (en Español)';
    } else if (targetLanguage == 'FR') {
      return 'Traduction: $text (en Français)';
    } else {
      return 'Translated ($targetLanguage): $text';
    }
  }

  Future<void> saveTranslation(String transcriptId, String content, String language) async {
    await _client.from('transcripts').update({
      'translated_content': content,
      'translated_language': language,
      'has_translation': true,
    }).eq('id', transcriptId);
  }
}
