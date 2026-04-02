"""
Session logging module.
Writes structured log entries to a timestamped file under /logs/.
"""

import os
import datetime

_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOGS_DIR  = os.path.join(_BASE_DIR, "logs")


class SessionLogger:
    def __init__(self):
        self._file       = None
        self._filepath   = None
        self._start_time = None
        self._entry_count = 0

    # ------------------------------------------------------------------
    # Session lifecycle
    # ------------------------------------------------------------------

    def start_session(self):
        os.makedirs(LOGS_DIR, exist_ok=True)
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self._filepath   = os.path.join(LOGS_DIR, f"session_{ts}.txt")
        self._start_time = datetime.datetime.now()
        self._entry_count = 0

        self._file = open(self._filepath, "w", encoding="utf-8")
        self._file.write(f"=== STT Session Log ===\n")
        self._file.write(f"Started : {self._start_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        self._file.write(f"{'='*40}\n\n")
        self._file.flush()

    def log_entry(self, text: str, processing_time: float):
        """Append a recognised sentence to the log file."""
        if not self._file or not text.strip():
            return
        self._entry_count += 1
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        line = f"[{ts}] ({processing_time:.2f}s)  {text}\n"
        self._file.write(line)
        self._file.flush()

    def end_session(self, total_time: float):
        if not self._file:
            return
        end_time = datetime.datetime.now()
        self._file.write(f"\n{'='*40}\n")
        self._file.write(f"Ended   : {end_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        self._file.write(f"Duration: {total_time:.1f}s\n")
        self._file.write(f"Entries : {self._entry_count}\n")
        self._file.close()
        self._file = None

    # ------------------------------------------------------------------
    # Accessors
    # ------------------------------------------------------------------

    @property
    def filepath(self):
        return self._filepath

    @property
    def entry_count(self):
        return self._entry_count
