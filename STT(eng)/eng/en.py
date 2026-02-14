import sys
import json
import time
import threading
from queue import Queue
import pyaudio
from vosk import Model, KaldiRecognizer
from datetime import datetime


class EchoSeeSTTOffline:
    def __init__(self):
        self.is_listening = False
        self.audio_queue = Queue()
        self.transcription_text = ""
        self.processing_time = 0
        self.model = None
        self.recognizer = None
        self.log_file = "echosee_offline_stt.log"
        self.last_partial = ""

    def initialize_vosk(self):
        """Initialize the English Vosk model"""
        try:
            print("Loading Vosk English model...")
            model_path = "vosk-model-small-en-us-0.15"  # English model folder
            self.model = Model(model_path)
            self.recognizer = KaldiRecognizer(self.model, 16000)
            self.recognizer.SetWords(True)
            print("Vosk (EN) model loaded successfully!")
            return True
        except Exception as e:
            print(f"Error loading Vosk model: {e}")
            return False

    def log_transcription(self, text, processing_time):
        """Log transcription to file"""
        try:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            log_entry = (
                f"[{timestamp}] EN: {text}\n"
                f"(Processing time: {processing_time:.2f} seconds)\n"
                + "-" * 50 + "\n"
            )
            with open(self.log_file, "a", encoding="utf-8") as f:
                f.write(log_entry)
            print(f"Logged to {self.log_file}")
        except Exception as e:
            print(f"Error writing to log file: {e}")

    def audio_callback(self, in_data, frame_count, time_info, status):
        """Callback for PyAudio"""
        if self.is_listening:
            self.audio_queue.put(in_data)
        return (in_data, pyaudio.paContinue)

    def process_audio_stream(self):
        """Process microphone audio"""
        print(" Listening... (Press Ctrl+C to stop)")
        print("-" * 60)

        audio = pyaudio.PyAudio()
        stream = audio.open(
            format=pyaudio.paInt16,
            channels=1,
            rate=16000,
            input=True,
            frames_per_buffer=4096,
            stream_callback=self.audio_callback
        )

        stream.start_stream()
        start_time = time.time()

        try:
            while self.is_listening:
                if not self.audio_queue.empty():
                    data = self.audio_queue.get()

                    if self.recognizer.AcceptWaveform(data):
                        result = json.loads(self.recognizer.Result())
                        if result.get('text'):
                            self.transcription_text = result['text']
                            if self.last_partial:
                                print("\r" + " " * (len(self.last_partial) + 10), end='', flush=True)
                            print(f"\r English: {self.transcription_text}")
                            self.last_partial = ""

                    # Partial feedback
                    partial_result = json.loads(self.recognizer.PartialResult())
                    if partial_result.get('partial'):
                        partial_text = partial_result['partial']
                        if partial_text and partial_text != self.last_partial:
                            if self.last_partial:
                                print("\r" + " " * (len(self.last_partial) + 10), end='', flush=True)
                            print(f"\r[Listening EN] {partial_text}", end='', flush=True)
                            self.last_partial = partial_text

                time.sleep(0.01)

        except KeyboardInterrupt:
            pass
        finally:
            end_time = time.time()
            self.processing_time = end_time - start_time

            if self.last_partial:
                print("\r" + " " * (len(self.last_partial) + 10), end='', flush=True)
                print("\r", end='', flush=True)

            final_result = json.loads(self.recognizer.FinalResult())
            if final_result.get('text'):
                self.transcription_text = final_result['text']

            stream.stop_stream()
            stream.close()
            audio.terminate()

    def start_recording(self):
        """Start recording session"""
        if not self.initialize_vosk():
            return

        self.is_listening = True
        self.transcription_text = ""
        self.last_partial = ""

        processing_thread = threading.Thread(target=self.process_audio_stream)
        processing_thread.daemon = True
        processing_thread.start()

        try:
            while processing_thread.is_alive():
                time.sleep(0.1)
        except KeyboardInterrupt:
            print("\nStopping recording...")
            self.is_listening = False
            processing_thread.join(timeout=2)

        self.display_final_results()

    def display_final_results(self):
        """Show transcription summary"""
        print("\n\n" + "=" * 60)
        print(" FINAL RESULTS")
        print("=" * 60)

        if self.transcription_text:
            print(f"\nEnglish (Recognized): '{self.transcription_text}'")
        else:
            print(" No speech detected.")

        print(f"\nProcessing Time: {self.processing_time:.2f} seconds")
        self.log_transcription(self.transcription_text, self.processing_time)
        print("=" * 60)


def main():
    print("EchoSee Real-Time Offline English STT (Speech-to-Text)")
    print("=" * 50)
    print("All operations are 100% offline.\n")

    stt_engine = EchoSeeSTTOffline()
    try:
        stt_engine.start_recording()
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        print("\nThank you for using EchoSee Offline STT!")


if __name__ == "__main__":
    main()
