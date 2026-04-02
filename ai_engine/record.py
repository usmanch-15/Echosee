import sounddevice as sd
from scipy.io.wavfile import write

fs = 16000
seconds = 5

print("🎤 Speak now...")

recording = sd.rec(int(seconds * fs), samplerate=fs, channels=1)
sd.wait()

write("speech.wav", fs, recording)

print("✅ Recording saved as speech.wav")