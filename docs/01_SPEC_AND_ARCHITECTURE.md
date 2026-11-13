# Specification & Architecture — DeutschTrainer Android

## 1. Layered Folder Structure (Flutter Best Practices)

```text
lib/
├── data/
│   ├── models/              # Persistence & platform DTOs
│   ├── repositories/        # DocumentRepository, DictationSessionRepository, SettingsRepository
│   └── services/            # SqliteService, FileImportService (.txt/.docx), GermanTtsService
├── domain/
│   ├── models/              # Document, Sentence, WordComparison, LiveTokenFeedback, PracticeStats
│   └── logic/               # Pure Dart deterministic logic (zero Flutter UI imports)
│       ├── german_tokenizer.dart
│       ├── word_comparator.dart
│       ├── live_prefix_comparator.dart
│       └── sentence_segmenter.dart
└── ui/
    ├── core/
    │   ├── theme/           # Material 3 Light/Dark theme, accessible green/red contrast tokens
    │   └── widgets/         # AdaptiveScaffold, GermanQuickCharsBar, AudioControlBar
    └── features/
        ├── library/         # Document import, library list, sentence preview
        │   ├── view_models/
        │   └── views/
        └── dictation/       # Listening, live green/red chips, show/hide original sentence, diff view
            ├── view_models/
            └── views/
```

## 2. Responsive Layout Strategy (All Phone & Tablet Screens)

### Measurement Rules
- Use `LayoutBuilder` and evaluate `constraints.maxWidth` (plus `MediaQuery.sizeOf(context)` and `MediaQuery.viewInsetsOf(context)` for software keyboard height).
- Never use `OrientationBuilder` at the app root or check physical hardware type.
- Do not lock portrait or landscape orientation.

### Adaptive Breakpoints
- **Compact Phones (`maxWidth <= 600`):**
  - Single-column vertical flow inside `SafeArea` + `CustomScrollView` / `SingleChildScrollView` so opening the soft keyboard never causes `RenderFlex overflowed`.
  - Bottom sticky or easily reachable thumb-zone controls for **Play/Replay Audio**, **Show/Hide Original Sentence**, and **Check Answer**.
  - Quick German character strip (`ä`, `ö`, `ü`, `ß`, `Ä`, `Ö`, `Ü`) directly above or docked cleanly with the dictation editor so learners do not have to hunt on non-German mobile keyboards.
- **Expanded / Landscape / Tablets (`maxWidth > 600`):**
  - Centered `ConstrainedBox(constraints: BoxConstraints(maxWidth: 840))` or split two-pane layout (`NavigationRail` / sentence list pane + `Expanded` dictation workspace).

## 3. Core Dictation UX Flow
1. Learner taps **Play (`Abspielen`)** -> `GermanTtsService` verifies an installed `de-DE` voice; displays actionable guidance if missing.
2. Learner types in the dictation field; when **Live-Feedback (Grün/Rot)** is enabled:
   - Each completed word and current typed token renders as a wrapped chip below/beside the input with:
     - **Green + check icon:** matches the corresponding reference token.
     - **Red + alert icon:** differs from the expected reference token (without leaking the hidden correct word!).
3. Learner can tap **Originalsatz anzeigen / ausblenden** at any time (before or after submission) to inspect the exact reference sentence in a dedicated high-contrast card and hide it again.
4. On **Prüfen**, deterministic word alignment displays exact matches, substitutions, missing words, extra words, capitalization differences, and punctuation differences.

## 4. Target Milestone Phases
1. **Phase 0 — Toolchain Bootstrap:** Install Flutter SDK + minimal Android SDK, run `flutter create`, confirm `flutter doctor` and empty app builds.
2. **Phase 1 — Pure Dart Domain Engine:** Implement & unit-test `german_tokenizer`, `word_comparator`, `live_prefix_comparator`, `sentence_segmenter`, and `.txt`/`.docx` parsing.
3. **Phase 2 — Persistence & Android `de-DE` TTS:** SQLite local repository + `flutter_tts` wrapper with explicit German voice verification and no-voice error UI.
4. **Phase 3 — Adaptive Material 3 UI:** Library screen + Dictation screen (`LayoutBuilder`, keyboard-safe layout, live green/red chips, show/hide original sentence toggle, German quick-char buttons) + widget tests across compact (`360x640`), standard (`412x915`), and tablet/landscape (`800x600`) screen constraints.
5. **Phase 4 — Android APK Build & Device Verification:** Build debug/release `.apk` and verify on a real Android phone or emulator.
