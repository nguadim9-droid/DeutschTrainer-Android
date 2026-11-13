import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState {
  stopped,
  playing,
  paused,
}

class GermanTtsService extends ChangeNotifier {
  final FlutterTts _tts;

  TtsPlaybackState _state = TtsPlaybackState.stopped;
  bool _hasGermanVoice = false;
  String? _errorMessage;
  double _speechRate = 0.45; // Comfortable learning speed
  String? _selectedVoice;

  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isPaused => _state == TtsPlaybackState.paused;
  bool get hasGermanVoice => _hasGermanVoice;
  String? get errorMessage => _errorMessage;
  double get speechRate => _speechRate;
  String? get selectedVoice => _selectedVoice;

  GermanTtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _initTts();
  }

  Future<void> _initTts() async {
    _tts.setStartHandler(() {
      _state = TtsPlaybackState.playing;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _state = TtsPlaybackState.stopped;
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      _state = TtsPlaybackState.stopped;
      notifyListeners();
    });

    _tts.setErrorHandler((msg) {
      _state = TtsPlaybackState.stopped;
      _errorMessage = 'TTS-Fehler: $msg';
      notifyListeners();
    });

    await checkGermanVoiceAvailability();
  }

  /// Verifies if a German voice (de-DE, de-AT, or de-CH) is installed on the Android system.
  Future<bool> checkGermanVoiceAvailability() async {
    try {
      final languages = await _tts.getLanguages;
      final isGermanSupported = languages is List &&
          languages.any((lang) =>
              lang.toString().toLowerCase().startsWith('de'));

      if (!isGermanSupported) {
        _hasGermanVoice = false;
        _errorMessage =
            'Keine deutsche Sprachausgabe (de-DE) auf diesem Gerät gefunden. Bitte installieren Sie deutsche Sprachdaten in den Android-Einstellungen (Bedienungshilfen > Text-in-Sprache).';
        notifyListeners();
        return false;
      }

      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);

      _hasGermanVoice = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _hasGermanVoice = false;
      _errorMessage = 'Fehler bei der Initialisierung des Sprachmoduls: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.2, 1.0);
    await _tts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_hasGermanVoice) {
      final available = await checkGermanVoiceAvailability();
      if (!available) return;
    }

    try {
      await _tts.stop();
      _state = TtsPlaybackState.playing;
      notifyListeners();
      await _tts.speak(text);
    } catch (e) {
      _state = TtsPlaybackState.stopped;
      _errorMessage = 'Wiedergabefehler: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } finally {
      _state = TtsPlaybackState.stopped;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
