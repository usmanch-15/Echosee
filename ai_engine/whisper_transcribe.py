import whisper

print("⏳ Loading model...")
model = whisper.load_model("base")  # you can use small, medium later

print("🧠 Transcribing...")
result = model.transcribe("speech.wav", language="ur")

print("\nFINAL TEXT:")
print(result["text"])