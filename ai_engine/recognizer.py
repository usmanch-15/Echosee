"""
STT Engine — loads faster-whisper model and transcribes audio buffers.
Handles both partial (live) and final transcription.
"""

import os
import numpy as np
from faster_whisper import WhisperModel

_BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Available models (name → relative snapshot path)
MODELS = {
    "base (recommended)": os.path.join(
        _BASE_DIR, "models",
        "models--Systran--faster-whisper-base",
        "snapshots",
        "ebe41f70d5b6dfa9166e2c581c45c9c0cfc57b66",
    ),
    "tiny (fast)": os.path.join(
        _BASE_DIR, "models",
        "models--Systran--faster-whisper-tiny",
        "snapshots",
        "d90ca5fe260221311c53c58e660288d3deb8d356",
    ),
}

DEFAULT_MODEL = "base (recommended)"
SAMPLE_RATE   = 16000

# Urdu initial prompt — primes the model to expect Urdu script
URDU_PROMPT = "یہ اردو میں گفتگو ہے۔"


class STTEngine:
    def __init__(self, on_status=None):
        self._model      = None
        self._model_name = DEFAULT_MODEL
        self._on_status  = on_status or (lambda msg: None)

    # ── model lifecycle ───────────────────────────────────────────────

    def load(self, model_name: str = DEFAULT_MODEL):
        self._model_name = model_name
        model_path = MODELS.get(model_name)
        if not model_path:
            raise RuntimeError(f"Unknown model: {model_name}")
        if not os.path.isdir(model_path):
            raise RuntimeError(f"Model files not found:\n{model_path}")

        self._on_status(f"Loading {model_name}…")
        try:
            self._model = WhisperModel(
                model_path,
                device="cpu",
                compute_type="int8",
                local_files_only=True,
            )
            self._on_status(f"Ready  [{model_name}]")
        except Exception as exc:
            raise RuntimeError(f"Failed to load model: {exc}") from exc

    @property
    def ready(self):
        return self._model is not None

    # ── transcription ─────────────────────────────────────────────────

    def transcribe(self, audio: np.ndarray, language: str = None,
                   use_vad: bool = False) -> str:
        if not self.ready or audio is None or len(audio) == 0:
            return ""

        audio = audio.astype(np.float32)
        if audio.max() > 1.0 or audio.min() < -1.0:
            audio = audio / 32768.0

        # Build kwargs
        kwargs = dict(
            language       = language or None,
            beam_size      = 5,
            best_of        = 5,
            temperature    = [0.0, 0.2, 0.4],   # retry with higher temp on failure
            vad_filter     = use_vad,
            word_timestamps= False,
            condition_on_previous_text=False,
            no_speech_threshold=0.5,
        )

        # Add Urdu initial prompt to guide the model
        if language == "ur":
            kwargs["initial_prompt"] = URDU_PROMPT

        try:
            segments, _ = self._model.transcribe(audio, **kwargs)
            return " ".join(seg.text.strip() for seg in segments).strip()
        except Exception:
            return ""
