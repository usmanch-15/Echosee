import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:echo_see_companion/data/models/transcript_model.dart';
import 'package:echo_see_companion/data/repositories/transcript_repository.dart';
import 'package:echo_see_companion/data/repositories/translation_repository.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';

class MockTranscriptRepository extends Mock implements TranscriptRepository {}
class MockTranslationRepository extends Mock implements TranslationRepository {}

// Add fake for Transcript to work with mocktail
class FakeTranscript extends Fake implements Transcript {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTranscript());
  });

  late TranscriptProvider provider;
  late MockTranscriptRepository mockRepository;
  late MockTranslationRepository mockTranslationRepository;

  setUp(() {
    mockRepository = MockTranscriptRepository();
    mockTranslationRepository = MockTranslationRepository();
    provider = TranscriptProvider(
      repository: mockRepository,
      translationRepository: mockTranslationRepository,
    );
  });

  group('TranscriptProvider TDD -', () {
    test('initial state should be empty and not loading', () {
      expect(provider.transcripts, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('loadTranscripts calls repository and updates state', () async {
      final List<Transcript> mockTranscripts = [
        Transcript(
          id: '1',
          title: 'Test',
          content: 'Content',
          date: DateTime.now(),
          duration: const Duration(minutes: 1),
          language: 'ENG',
          speakerSegments: [],
        )
      ];

      when(() => mockRepository.getTranscripts(limit: any(named: 'limit')))
          .thenAnswer((_) async => mockTranscripts);

      await provider.loadTranscripts();

      expect(provider.transcripts.length, 1);
      expect(provider.transcripts[0].id, '1');
      expect(provider.isLoading, false);
      verify(() => mockRepository.getTranscripts(limit: 50)).called(1);
    });

    test('saveTranscript updates both repository and local state', () async {
      final newTranscript = Transcript(
        id: 'new',
        title: 'New',
        content: 'New content',
        date: DateTime.now(),
        duration: const Duration(seconds: 30),
        language: 'ENG',
        speakerSegments: [],
      );

      when(() => mockRepository.saveTranscript(any()))
          .thenAnswer((_) async => newTranscript);
      when(() => mockRepository.getTranscripts(limit: any(named: 'limit')))
          .thenAnswer((_) async => [newTranscript]);

      await provider.saveTranscript(newTranscript);

      verify(() => mockRepository.saveTranscript(newTranscript)).called(1);
      expect(provider.transcripts.length, 1);
    });

    test('deleteTranscript removes from repository and local list', () async {
      final transcript = Transcript(
        id: 'del',
        title: 'Del',
        content: 'Del',
        date: DateTime.now(),
        duration: const Duration(seconds: 10),
        language: 'ENG',
        speakerSegments: [],
      );

      // Initial state with one transcript
      when(() => mockRepository.getTranscripts(limit: any(named: 'limit')))
          .thenAnswer((_) async => [transcript]);
      await provider.loadTranscripts();

      when(() => mockRepository.deleteTranscript('del')).thenAnswer((_) async => {});

      await provider.deleteTranscript('del');

      verify(() => mockRepository.deleteTranscript('del')).called(1);
      expect(provider.transcripts, isEmpty);
    });

    test('updateSpeakerName modifies local state optimistically', () async {
      final transcript = Transcript(
        id: 'spk',
        title: 'Spk',
        content: 'Spk',
        date: DateTime.now(),
        duration: const Duration(seconds: 10),
        language: 'ENG',
        speakerSegments: [
          SpeakerSegment(speakerId: 1, text: 'Hello', startTime: Duration.zero, endTime: const Duration(seconds: 5))
        ],
      );

      when(() => mockRepository.getTranscripts(limit: any(named: 'limit')))
          .thenAnswer((_) async => [transcript]);
      await provider.loadTranscripts();

      when(() => mockRepository.saveTranscript(any())).thenAnswer((i) async => i.positionalArguments[0] as Transcript);

      await provider.updateSpeakerName('spk', 1, 'Roman');

      expect(provider.transcripts[0].speakerSegments[0].speakerName, 'Roman');
      verify(() => mockRepository.saveTranscript(any())).called(1);
    });
  });
}
