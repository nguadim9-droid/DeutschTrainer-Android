# DeutschTrainer Android (Flutter)

Offline-first German listening & typed dictation trainer built with **Flutter (Dart)** for Android phones and tablets (and adaptable across screen sizes).

## Core Features (Version 1 Scope)
- **Adaptive Mobile UI:** Responsive layout using `LayoutBuilder`, `MediaQuery.sizeOf(context)`, `SafeArea`, and keyboard-aware scrolling so dictation remains comfortable on compact phones, large phones, foldables, and tablets in portrait or landscape.
- **German Listening Practice:** Verified `de-DE` Text-to-Speech playback with rate control (where supported by the device TTS engine) and clear error messages if no German voice is installed.
- **Live Word-by-Word Feedback (Green / Red):** Instant prefix comparison highlighting correctly typed German words in green and mismatched words in red as you type.
- **Show / Hide Original Sentence Toggle:** Explicit toggle button so learners can check the exact reference sentence at any time and hide it again; hidden by default on every new sentence.
- **Document Import:** Local import of `.txt` (UTF-8) and `.docx` documents with sentence segmentation and strict Unicode preservation (`ä`, `ö`, `ü`, `Ä`, `Ö`, `Ü`, `ß`).

## Out of Scope (Version 1)
- Microphone capture, speech recording, Speech-to-Text (STT), or pronunciation scoring.
- AI chat tutors, automatic translation, or automatic rewriting of source sentences.
- Cloud accounts, telemetry, or hidden network uploads.

## Documentation
- [`AGENTS.md`](./AGENTS.md) — Engineering and scope rules for the Android Flutter project.
- [`docs/01_SPEC_AND_ARCHITECTURE.md`](./docs/01_SPEC_AND_ARCHITECTURE.md) — MVVM + Repository layered architecture & responsive UI layout specification.
- [`docs/02_ENVIRONMENT_AND_SETUP.md`](./docs/02_ENVIRONMENT_AND_SETUP.md) — Toolchain prerequisites, disk space notes, and next setup steps.
