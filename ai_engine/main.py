"""
Entry point — initialises and launches the Offline STT GUI.
Run with:  python main.py
"""

from gui import STTApp


def main():
    app = STTApp()
    app.protocol("WM_DELETE_WINDOW", app.on_close)
    app.mainloop()


if __name__ == "__main__":
    main()
