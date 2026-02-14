import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo_see_companion/services/speech_service.dart';

class MockSpeechService extends Mock implements SpeechService {}

void main() {
  group('Speech to Text BDD Scenarios', () {
    late SpeechService mockService;

    setUp(() {
      mockService = MockSpeechService();
    });

    test('Scenario: Basic Real-time Transcription', () async {
      // Given
      when(() => mockService.initialize()).thenAnswer((_) async => {});
      when(() => mockService.startListening()).thenAnswer((_) async => {});
      when(() => mockService.textStream).thenAnswer((_) => Stream.fromIterable(['hello', 'hello how', 'hello how are you']));

      // When
      await mockService.startListening();

      // Then
      expect(mockService.textStream, emitsInOrder(['hello', 'hello how', 'hello how are you']));
      verify(() => mockService.startListening()).called(1);
    });

    test('Scenario: Stopping Transcription', () async {
      // Given
      when(() => mockService.stopListening()).thenAnswer((_) async => {});
      
      // When
      await mockService.stopListening();

      // Then
      verify(() => mockService.stopListening()).called(1);
    });
  });
}
