import 'package:flutter/foundation.dart';
import '../../../../data/services/german_tts_service.dart';
import '../../../../domain/logic/live_prefix_comparator.dart';
import '../../../../domain/logic/word_comparator.dart';
import '../../../../domain/models/comparison_result.dart';
import '../../../../domain/models/document.dart';
import '../../../../domain/models/live_token_feedback.dart';
import '../../../../domain/models/sentence.dart';

class DictationViewModel extends ChangeNotifier {
  final GermanTtsService _ttsService;

  Document? _document;
  int _currentIndex = 0;
  String _typedText = '';
  bool _isRevealed = false; // Always starts hidden!
  bool _liveFeedbackEnabled = true;
  bool _strictCase = true;
  ComparisonResult? _comparisonResult;
  List<LiveTokenFeedback> _liveTokens = const [];

  DictationViewModel({required GermanTtsService ttsService})
      : _ttsService = ttsService;

  Document? get document => _document;
  int get currentIndex => _currentIndex;
  int get totalSentences => _document?.sentences.length ?? 0;
  Sentence? get currentSentence => (_document != null &&
          _currentIndex >= 0 &&
          _currentIndex < _document!.sentences.length)
      ? _document!.sentences[_currentIndex]
      : null;

  String get typedText => _typedText;
  bool get isRevealed => _isRevealed;
  bool get liveFeedbackEnabled => _liveFeedbackEnabled;
  bool get strictCase => _strictCase;
  ComparisonResult? get comparisonResult => _comparisonResult;
  List<LiveTokenFeedback> get liveTokens => _liveTokens;
  GermanTtsService get ttsService => _ttsService;

  void startSession(Document document, [int initialIndex = 0]) {
    _document = document;
    _currentIndex = initialIndex.clamp(0, document.sentences.length - 1);
    _resetSentenceState();
    notifyListeners();

    // Auto-play audio when sentence opens
    playAudio();
  }

  void _resetSentenceState() {
    _typedText = '';
    _isRevealed = false; // Reset to hidden on every new sentence
    _comparisonResult = null;
    _liveTokens = const [];
  }

  Future<void> playAudio() async {
    final sentence = currentSentence;
    if (sentence != null) {
      await _ttsService.speak(sentence.referenceText);
    }
  }

  Future<void> stopAudio() async {
    await _ttsService.stop();
  }

  void toggleReveal() {
    _isRevealed = !_isRevealed;
    notifyListeners();
  }

  void toggleLiveFeedback(bool enabled) {
    _liveFeedbackEnabled = enabled;
    if (!enabled) {
      _liveTokens = const [];
    } else if (currentSentence != null) {
      _liveTokens = LivePrefixComparator.compareLive(
        referenceText: currentSentence!.referenceText,
        typedText: _typedText,
        strictCase: _strictCase,
      );
    }
    notifyListeners();
  }

  void updateTypedText(String newText) {
    _typedText = newText;

    if (_liveFeedbackEnabled && currentSentence != null) {
      _liveTokens = LivePrefixComparator.compareLive(
        referenceText: currentSentence!.referenceText,
        typedText: newText,
        strictCase: _strictCase,
      );
    }

    notifyListeners();
  }

  void submit() {
    final sentence = currentSentence;
    if (sentence == null) return;

    _comparisonResult = WordComparator.compare(
      referenceText: sentence.referenceText,
      learnerText: _typedText,
      strictCase: _strictCase,
    );

    notifyListeners();
  }

  void retry() {
    _typedText = '';
    _comparisonResult = null;
    _liveTokens = const [];
    notifyListeners();
    playAudio();
  }

  void nextSentence() {
    if (_document != null && _currentIndex < _document!.sentences.length - 1) {
      _currentIndex++;
      _resetSentenceState();
      notifyListeners();
      playAudio();
    }
  }

  void previousSentence() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetSentenceState();
      notifyListeners();
      playAudio();
    }
  }
}
