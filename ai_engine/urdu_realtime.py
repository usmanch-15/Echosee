# urdu_realtime_working.py
from faster_whisper import WhisperModel
import sounddevice as sd
import numpy as np
import tempfile
import wave
import os
import time
import signal
import sys

# ===================== CONFIG =====================
SAMPLE_RATE = 16000
CHUNK_DURATION = 3  # seconds
MODEL_SIZE = "tiny"  # Use "base" for better accuracy
MODEL_PATH = "./models/models--Systran--faster-whisper-tiny/snapshots/d90ca5fe260221311c53c58e660288d3deb8d356/"

class UrduRealtimeSTT:
    def __init__(self):
        self.model = None
        self.is_running = False
        
    def load_model(self):
        """Load faster-whisper model from local path"""
        print(f"⏳ Loading Urdu Whisper model ({MODEL_SIZE})...")
        start_time = time.time()
        
        try:
            # Load from local path
            self.model = WhisperModel(
                MODEL_PATH,
                device="cpu",
                compute_type="int8",
                cpu_threads=4,
                num_workers=1
            )
            load_time = time.time() - start_time
            print(f"✅ Model loaded in {load_time:.2f} seconds")
            return True
        except Exception as e:
            print(f"❌ Failed to load model: {e}")
            return False
    
    def record_chunk(self, duration):
        """Record audio chunk"""
        recording = sd.rec(int(duration * SAMPLE_RATE),
                          samplerate=SAMPLE_RATE,
                          channels=1,
                          dtype=np.int16)
        sd.wait()
        return recording.flatten()
    
    def transcribe_chunk(self, audio_chunk):
        """Transcribe audio chunk"""
        # Save to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
            wf = wave.open(tmp.name, 'wb')
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(SAMPLE_RATE)
            wf.writeframes(audio_chunk.tobytes())
            wf.close()
            
            # Transcribe
            segments, _ = self.model.transcribe(
                tmp.name,
                language="ur",
                beam_size=5,
                condition_on_previous_text=False
            )
            
            # Get text
            text = " ".join([seg.text for seg in segments]).strip()
            
            # Cleanup
            os.unlink(tmp.name)
            
            return text
    
    def run(self):
        """Main recognition loop"""
        if not self.load_model():
            return
        
        self.is_running = True
        
        def signal_handler(sig, frame):
            print("\n\n👋 Stopping...")
            self.is_running = False
            sys.exit(0)
        
        signal.signal(signal.SIGINT, signal_handler)
        
        print("\n" + "="*50)
        print("🎤 URDU SPEECH RECOGNITION READY")
        print("Speak clearly into the microphone")
        print(f"Processing {CHUNK_DURATION}-second chunks")
        print("Press Ctrl+C to stop")
        print("="*50 + "\n")
        
        while self.is_running:
            try:
                # Record
                print("🎙 Recording...", end="", flush=True)
                audio = self.record_chunk(CHUNK_DURATION)
                
                # Transcribe
                print("\r🧠 Transcribing...", end="", flush=True)
                text = self.transcribe_chunk(audio)
                
                # Display result
                if text:
                    print(f"\r✅ {text}")
                else:
                    print("\r⏺️  (no speech detected)")
                    
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"\r❌ Error: {e}")
                continue

if __name__ == "__main__":
    stt = UrduRealtimeSTT()
    stt.run()