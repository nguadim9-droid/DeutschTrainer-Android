# DeutschTrainer Android — Project Engineering Rules

## 1. Product Boundary (Version 1)
- **Allowed:** Listening (`de-DE` TTS), typed dictation, deterministic word-level comparison (post-submit and live green/red prefix feedback), explicit show/hide original sentence toggle, and local `.txt`/`.docx` import.
- **Excluded:** Microphone permission (`RECORD_AUDIO`), voice recording, Speech-to-Text, speaking/pronunciation grading, LLM/AI grammar tutors, automatic translation, and unapproved network calls.

## 2. Text Integrity Rules
- Never silently mutate or auto-correct imported German text or learner input.
- Preserve exact Unicode characters (`ä`, `ö`, `ü`, `Ä`, `Ö`, `Ü`, `ß`) and punctuation.
- Keep the reference sentence hidden by default on each sentence until the learner taps the explicit reveal toggle.

## 3. Architecture & Code Quality
- Follow strict MVVM + Repository separation (`ui/` -> `domain/` -> `data/`).
- Keep business rules (German tokenization, Myers/LCS word alignment, prefix comparison, sentence segmentation) pure Dart in `lib/domain/` with full unit tests in `test/`.
- No orientation lock (`ScreenOrientation` remains unlocked); adapt layouts strictly from available window constraints (`LayoutBuilder` / `MediaQuery.sizeOf(context)`), never hardcoded phone-vs-tablet device checks.
- Pair every status color (green/red) with clear text, icons, or accessibility semantics (`Semantics`).

## 4. Verification Before Claiming Done
- Run `dart analyze`, `flutter test`, and Android build verification (`flutter build apk --debug` / `--release`) after edits.
- Never report tests or builds as passing unless actually executed and observed passing.
