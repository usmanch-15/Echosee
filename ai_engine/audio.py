"""
Audio capture layer with chunk-based streaming and automatic resampling.

Captures microphone audio at the device's native sample rate,
resamples each chunk to 16 000 Hz (required by faster-whisper),
then pushes chunks into a queue for the STT processing thread.
"""

import queue
import numpy as np
import sounddevice as sd

TARGET_RATE   = 16000   # Hz required by faster-whisper
CHUNK_SAMPLES = 1024    # output chunk size after resampling (~64 ms)
CHANNELS      = 1


def list_input_devices():
    """Return list of (index, name) for all input devices."""
    devices = []
    for i, d in enumerate(sd.query_devices()):
        if d["max_input_channels"] > 0:
            devices.append((i, d["name"]))
    return devices


def get_device_native_rate(device_index):
    """Return the default sample rate of a device."""
    return int(sd.query_devices(device_index)["default_samplerate"])


def _resample(audio: np.ndarray, orig_rate: int, target_rate: int) -> np.ndarray:
    """Linear-interpolation resample from orig_rate to target_rate."""
    if orig_rate == target_rate:
        return audio
    duration   = len(audio) / orig_rate
    target_len = max(1, int(round(duration * target_rate)))
    return np.interp(
        np.linspace(0, len(audio) - 1, target_len),
        np.arange(len(audio)),
        audio,
    ).astype(np.float32)


class AudioCapture:
    def __init__(self, device_index: int = None, on_error=None):
        self._queue        = queue.Queue()
        self._stream       = None
        self._running      = False
        self._device_index = device_index
        self._native_rate  = TARGET_RATE
        self._on_error     = on_error or (lambda e: None)

        # Resample buffer — accumulate native chunks until we have
        # enough to produce one CHUNK_SAMPLES output chunk
        self._resample_buf = np.array([], dtype=np.float32)

    # ── public API ────────────────────────────────────────────────────

    def start(self):
        if self._device_index is None:
            # fall back to system default input
            self._device_index = sd.query_devices(kind="input")["index"]

        self._native_rate  = get_device_native_rate(self._device_index)
        self._resample_buf = np.array([], dtype=np.float32)
        self._running      = True

        # Use a blocksize that covers ~64 ms at the native rate
        native_block = int(self._native_rate * CHUNK_SAMPLES / TARGET_RATE)

        self._stream = sd.InputStream(
            device=self._device_index,
            samplerate=self._native_rate,
            channels=CHANNELS,
            dtype="float32",
            blocksize=native_block,
            callback=self._callback,
        )
        self._stream.start()

    def stop(self):
        self._running = False
        if self._stream is not None:
            try:
                self._stream.stop()
                self._stream.close()
            except Exception:
                pass
            self._stream = None

    def read_chunk(self, timeout: float = 0.1):
        """Return next float32 1-D chunk at TARGET_RATE, or None on timeout."""
        try:
            return self._queue.get(timeout=timeout)
        except queue.Empty:
            return None

    def flush(self):
        self._resample_buf = np.array([], dtype=np.float32)
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except queue.Empty:
                break

    @property
    def device_index(self):
        return self._device_index

    # ── internal ──────────────────────────────────────────────────────

    def _callback(self, indata, frames, time_info, status):
        if not self._running:
            return
        chunk = indata[:, 0].copy()

        # Resample to TARGET_RATE
        resampled = _resample(chunk, self._native_rate, TARGET_RATE)

        # Accumulate and emit fixed-size output chunks
        self._resample_buf = np.concatenate([self._resample_buf, resampled])
        while len(self._resample_buf) >= CHUNK_SAMPLES:
            self._queue.put(self._resample_buf[:CHUNK_SAMPLES].copy())
            self._resample_buf = self._resample_buf[CHUNK_SAMPLES:]
