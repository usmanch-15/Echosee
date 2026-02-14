Feature: Offline Speech to Text
  As a user who values privacy and offline access
  I want to transcribe my speech to text without an internet connection
  So that I can see subtitles on my smart glasses companion app

  Background:
    Given the app is initialized
    And the Vosk model for English is loaded

  Scenario: Basic Real-time Transcription
    When I tap the "START RECORDING" button
    And I speak "hello how are you"
    Then I should see the text "hello how are you" on the screen

  Scenario: Stopping Transcription
    Given I am currently recording
    When I tap the "STOP RECORDING" button
    Then the recording should stop
    And a new transcript should be saved in the history
