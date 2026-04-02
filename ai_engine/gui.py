"""
GUI — Tkinter-based interface for the Offline STT system.

Layout:
  ┌──────────────────────────────────────┐
  │  Offline STT System       ● READY   │
  ├──────────────────────────────────────┤
  │  Microphone: [dropdown]              │
  ├──────────────────────────────────────┤
  │  Live Partial:                       │
  │  [ partial text area ]               │
  ├──────────────────────────────────────┤
  │  Final Transcription:                │
  │  [ scrollable output area ]          │
  ├──────────────────────────────────────┤
  │  [ ▶ Start ]  [ ■ Stop ]  [ Clear ] │
  │  [ Save Log ]                        │
  ├──────────────────────────────────────┤
  │  Time: 00:00    Sentences: 0        │
  └──────────────────────────────────────┘
"""

import tkinter as tk
from tkinter import scrolledtext, messagebox, filedialog, ttk
import threading
import time
import datetime
import numpy as np

from audio      import AudioCapture, list_input_devices, TARGET_RATE
from recognizer import STTEngine, MODELS
from logger     import SessionLogger

# ── tunables ──────────────────────────────────────────────────────────
SILENCE_THRESHOLD    = 0.015   # RMS below this → silence
SILENCE_FRAMES       = 14      # consecutive silent chunks (~0.87s) → finalise
PARTIAL_INTERVAL_SEC = 1.5     # re-transcribe partial every N seconds
MIN_BUFFER_SEC       = 1.0     # don't transcribe until we have this much audio
MAX_BUFFER_SEC       = 10.0    # hard cap — finalise regardless of silence

# Language codes
LANGUAGES = {
    "Auto Detect": None,
    "English":     "en",
    "Urdu":        "ur",
}

# ── colour palette ────────────────────────────────────────────────────
BG      = "#1e1e2e"
BG2     = "#2a2a3e"
FG      = "#cdd6f4"
ACCENT  = "#89b4fa"
PARTIAL = "#f9e2af"
SUCCESS = "#a6e3a1"
DANGER  = "#f38ba8"
MUTED   = "#6c7086"
BORDER  = "#45475a"


class STTApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Offline STT System")
        self.geometry("720x640")
        self.minsize(600, 520)
        self.configure(bg=BG)

        self._engine  = STTEngine(on_status=self._set_status)
        self._capture = AudioCapture()
        self._logger  = SessionLogger()

        self._listening      = False
        self._proc_thread    = None
        self._timer_thread   = None
        self._session_start  = None
        self._sentence_count = 0

        self._build_ui()
        self._populate_devices()
        self._model_var.trace_add("write", self._on_model_changed)
        self._load_model_async()

    # ══════════════════════════════════════════════════════════════════
    # UI construction
    # ══════════════════════════════════════════════════════════════════

    def _build_ui(self):
        # ── header ───────────────────────────────────────────────────
        header = tk.Frame(self, bg=BG2, pady=10)
        header.pack(fill=tk.X)

        tk.Label(header, text="Offline STT System",
                 font=("Segoe UI", 16, "bold"), bg=BG2, fg=FG
                 ).pack(side=tk.LEFT, padx=16)

        self._status_dot   = tk.Label(header, text="●", font=("Segoe UI", 14),
                                      bg=BG2, fg=MUTED)
        self._status_label = tk.Label(header, text="Initialising…",
                                      font=("Segoe UI", 10), bg=BG2, fg=MUTED)
        self._status_dot.pack(side=tk.RIGHT, padx=(0, 16))
        self._status_label.pack(side=tk.RIGHT)

        # ── settings row (mic + language + model) ────────────────────
        dev_frame = tk.Frame(self, bg=BG, pady=4)
        dev_frame.pack(fill=tk.X, padx=12, pady=(6, 2))

        tk.Label(dev_frame, text="Mic:", font=("Segoe UI", 10),
                 bg=BG, fg=FG).pack(side=tk.LEFT, padx=(0, 4))

        self._device_var = tk.StringVar()
        self._device_box = ttk.Combobox(
            dev_frame, textvariable=self._device_var,
            state="readonly", width=30, font=("Segoe UI", 9),
        )
        self._device_box.pack(side=tk.LEFT, padx=(0, 12))

        tk.Label(dev_frame, text="Language:", font=("Segoe UI", 10),
                 bg=BG, fg=FG).pack(side=tk.LEFT, padx=(0, 4))

        self._lang_var = tk.StringVar(value="Auto Detect")
        self._lang_box = ttk.Combobox(
            dev_frame, textvariable=self._lang_var,
            values=list(LANGUAGES.keys()),
            state="readonly", width=12, font=("Segoe UI", 9),
        )
        self._lang_box.pack(side=tk.LEFT, padx=(0, 12))

        tk.Label(dev_frame, text="Model:", font=("Segoe UI", 10),
                 bg=BG, fg=FG).pack(side=tk.LEFT, padx=(0, 4))

        self._model_var = tk.StringVar(value=list(MODELS.keys())[0])
        self._model_box = ttk.Combobox(
            dev_frame, textvariable=self._model_var,
            values=list(MODELS.keys()),
            state="readonly", width=20, font=("Segoe UI", 9),
        )
        self._model_box.pack(side=tk.LEFT)

        # style the comboboxes
        style = ttk.Style()
        style.theme_use("default")
        style.configure("TCombobox",
                         fieldbackground=BG2, background=BG2,
                         foreground=FG, selectbackground=ACCENT,
                         selectforeground=BG)

        # ── partial result ────────────────────────────────────────────
        pf = tk.LabelFrame(self, text=" Live Partial ",
                           font=("Segoe UI", 9), bg=BG, fg=ACCENT,
                           bd=1, relief=tk.FLAT)
        pf.pack(fill=tk.X, padx=12, pady=(6, 2))

        self._partial_var = tk.StringVar(value="")
        tk.Label(pf, textvariable=self._partial_var,
                 font=("Segoe UI", 12, "italic"),
                 bg=BG, fg=PARTIAL, wraplength=660,
                 justify=tk.LEFT, anchor="w", height=2,
                 ).pack(fill=tk.X, padx=8, pady=6)

        # ── final transcript ──────────────────────────────────────────
        of = tk.LabelFrame(self, text=" Final Transcription ",
                           font=("Segoe UI", 9), bg=BG, fg=ACCENT,
                           bd=1, relief=tk.FLAT)
        of.pack(fill=tk.BOTH, expand=True, padx=12, pady=2)

        self._output = scrolledtext.ScrolledText(
            of, font=("Consolas", 11),
            bg=BG2, fg=FG, insertbackground=FG,
            bd=0, relief=tk.FLAT, state=tk.DISABLED, wrap=tk.WORD,
        )
        self._output.pack(fill=tk.BOTH, expand=True, padx=4, pady=4)
        self._output.tag_config("sentence", foreground=SUCCESS)
        self._output.tag_config("ts",       foreground=MUTED)

        # ── controls ──────────────────────────────────────────────────
        ctrl = tk.Frame(self, bg=BG, pady=6)
        ctrl.pack(fill=tk.X, padx=12)

        btn = dict(font=("Segoe UI", 11, "bold"), bd=0, relief=tk.FLAT,
                   padx=18, pady=6, cursor="hand2")

        self._btn_start = tk.Button(ctrl, text="▶  Start", bg=ACCENT, fg=BG,
                                    command=self._start_session, **btn)
        self._btn_start.pack(side=tk.LEFT, padx=(0, 8))

        self._btn_stop = tk.Button(ctrl, text="■  Stop", bg=DANGER, fg=BG,
                                   command=self._stop_session,
                                   state=tk.DISABLED, **btn)
        self._btn_stop.pack(side=tk.LEFT, padx=(0, 8))

        tk.Button(ctrl, text="Clear", bg=BG2, fg=FG,
                  command=self._clear_output, **btn).pack(side=tk.LEFT, padx=(0, 8))

        tk.Button(ctrl, text="Save Log", bg=BG2, fg=FG,
                  command=self._save_log, **btn).pack(side=tk.LEFT)

        # ── stats bar ─────────────────────────────────────────────────
        stats = tk.Frame(self, bg=BG2, pady=5)
        stats.pack(fill=tk.X, side=tk.BOTTOM)

        self._timer_var = tk.StringVar(value="Time: 00:00")
        self._count_var = tk.StringVar(value="Sentences: 0")

        tk.Label(stats, textvariable=self._timer_var,
                 font=("Segoe UI", 9), bg=BG2, fg=MUTED).pack(side=tk.LEFT, padx=16)
        tk.Label(stats, textvariable=self._count_var,
                 font=("Segoe UI", 9), bg=BG2, fg=MUTED).pack(side=tk.LEFT, padx=8)

    # ══════════════════════════════════════════════════════════════════
    # Device population
    # ══════════════════════════════════════════════════════════════════

    def _populate_devices(self):
        self._devices = list_input_devices()   # [(index, name), ...]
        names = [f"[{i}] {n}" for i, n in self._devices]
        self._device_box["values"] = names

        # Pre-select: prefer Realtek/built-in, avoid DroidCam/Bluetooth
        preferred_idx = 0
        for pos, (idx, name) in enumerate(self._devices):
            low = name.lower()
            if any(k in low for k in ("realtek", "microphone array", "hd audio mic")):
                preferred_idx = pos
                break

        if names:
            self._device_box.current(preferred_idx)

    def _selected_device_index(self):
        pos = self._device_box.current()
        if pos < 0 or pos >= len(self._devices):
            return None
        return self._devices[pos][0]

    # ══════════════════════════════════════════════════════════════════
    # Model loading
    # ══════════════════════════════════════════════════════════════════

    def _load_model_async(self, model_name: str = None):
        self._btn_start.config(state=tk.DISABLED)
        if model_name is None:
            model_name = self._model_var.get()

        def _load():
            try:
                self._engine.load(model_name)
                self.after(0, lambda: self._btn_start.config(state=tk.NORMAL))
            except RuntimeError as e:
                self.after(0, lambda: self._set_status("Model error", DANGER))
                self.after(0, lambda: messagebox.showerror("Model Error", str(e)))

        threading.Thread(target=_load, daemon=True).start()

    def _on_model_changed(self, *_):
        """Reload model when user changes the model dropdown."""
        if not self._listening:
            self._engine = STTEngine(on_status=self._set_status)
            self._load_model_async(self._model_var.get())

    # ══════════════════════════════════════════════════════════════════
    # Session control
    # ══════════════════════════════════════════════════════════════════

    def _start_session(self):
        if self._listening:
            return

        dev_idx = self._selected_device_index()
        if dev_idx is None:
            messagebox.showerror("No Device", "Please select a microphone.")
            return

        self._listening      = True
        self._sentence_count = 0
        self._session_start  = time.time()
        self._count_var.set("Sentences: 0")

        self._logger.start_session()

        # Recreate capture with selected device
        self._capture = AudioCapture(device_index=dev_idx)
        self._capture.flush()

        try:
            self._capture.start()
        except Exception as e:
            self._listening = False
            messagebox.showerror("Microphone Error", str(e))
            return

        self._btn_start.config(state=tk.DISABLED)
        self._btn_stop.config(state=tk.NORMAL)
        self._device_box.config(state=tk.DISABLED)
        self._lang_box.config(state=tk.DISABLED)
        self._model_box.config(state=tk.DISABLED)
        self._set_status("Listening…", SUCCESS)
        self._status_dot.config(fg=SUCCESS)

        self._proc_thread  = threading.Thread(target=self._processing_loop, daemon=True)
        self._timer_thread = threading.Thread(target=self._timer_loop,      daemon=True)
        self._proc_thread.start()
        self._timer_thread.start()

    def _stop_session(self):
        if not self._listening:
            return
        self._listening = False
        self._capture.stop()

        elapsed = time.time() - self._session_start if self._session_start else 0
        self._logger.end_session(elapsed)

        self._btn_start.config(state=tk.NORMAL)
        self._btn_stop.config(state=tk.DISABLED)
        self._device_box.config(state="readonly")
        self._lang_box.config(state="readonly")
        self._model_box.config(state="readonly")
        self._set_status("Stopped", MUTED)
        self._status_dot.config(fg=MUTED)
        self._partial_var.set("")

    # ══════════════════════════════════════════════════════════════════
    # Processing loop  (background thread)
    # ══════════════════════════════════════════════════════════════════

    def _processing_loop(self):
        buffer:         list  = []
        buffer_secs:    float = 0.0
        silent_frames:  int   = 0
        had_speech:     bool  = False
        last_partial_t: float = time.time()
        last_partial:   str   = ""

        # Snapshot language at session start
        lang_code = LANGUAGES.get(self._lang_var.get())

        while self._listening:
            chunk = self._capture.read_chunk(timeout=0.05)
            if chunk is None:
                continue

            rms       = float(np.sqrt(np.mean(chunk ** 2)))
            is_silent = rms < SILENCE_THRESHOLD

            buffer.append(chunk)
            buffer_secs += len(chunk) / TARGET_RATE

            if is_silent:
                silent_frames += 1
            else:
                silent_frames = 0
                had_speech    = True

            # ── partial ───────────────────────────────────────────────
            now = time.time()
            if (now - last_partial_t >= PARTIAL_INTERVAL_SEC
                    and buffer_secs >= MIN_BUFFER_SEC):
                audio_buf = np.concatenate(buffer)
                partial   = self._engine.transcribe(audio_buf, language=lang_code)
                if partial and partial != last_partial:
                    last_partial = partial
                    self.after(0, lambda t=partial: self._partial_var.set(t))
                last_partial_t = now

            # ── finalise ──────────────────────────────────────────────
            should_finalise = had_speech and (
                silent_frames >= SILENCE_FRAMES or buffer_secs >= MAX_BUFFER_SEC
            )

            if should_finalise and buffer_secs >= MIN_BUFFER_SEC:
                t0        = time.time()
                audio_buf = np.concatenate(buffer)
                final     = self._engine.transcribe(
                    audio_buf, language=lang_code, use_vad=True
                )
                proc_time = time.time() - t0

                if final:
                    self._logger.log_entry(final, proc_time)
                    self.after(0, lambda t=final, p=proc_time: self._add_sentence(t, p))

                buffer         = []
                buffer_secs    = 0.0
                silent_frames  = 0
                had_speech     = False
                last_partial   = ""
                last_partial_t = time.time()
                self.after(0, lambda: self._partial_var.set(""))

    # ══════════════════════════════════════════════════════════════════
    # UI helpers
    # ══════════════════════════════════════════════════════════════════

    def _add_sentence(self, text: str, proc_time: float):
        self._sentence_count += 1
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        self._output.config(state=tk.NORMAL)
        self._output.insert(tk.END, f"[{ts}] ", "ts")
        self._output.insert(tk.END, f"{text}\n", "sentence")
        self._output.insert(tk.END, f"  ↳ {proc_time:.2f}s\n\n", "ts")
        self._output.see(tk.END)
        self._output.config(state=tk.DISABLED)
        self._count_var.set(f"Sentences: {self._sentence_count}")

    def _set_status(self, msg: str, colour: str = MUTED):
        self._status_label.config(text=msg, fg=colour)
        self._status_dot.config(fg=colour)

    def _clear_output(self):
        self._output.config(state=tk.NORMAL)
        self._output.delete("1.0", tk.END)
        self._output.config(state=tk.DISABLED)
        self._partial_var.set("")
        self._sentence_count = 0
        self._count_var.set("Sentences: 0")

    def _save_log(self):
        path = self._logger.filepath
        if not path:
            messagebox.showinfo("Save Log", "No session log exists yet.")
            return
        dest = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
            initialfile=path,
        )
        if dest:
            import shutil
            shutil.copy2(path, dest)
            messagebox.showinfo("Saved", f"Log saved to:\n{dest}")

    def _timer_loop(self):
        while self._listening:
            elapsed = int(time.time() - self._session_start)
            m, s    = divmod(elapsed, 60)
            self.after(0, lambda m=m, s=s: self._timer_var.set(f"Time: {m:02d}:{s:02d}"))
            time.sleep(1)

    def on_close(self):
        if self._listening:
            self._stop_session()
        self.destroy()
