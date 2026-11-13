import '../models/live_token_feedback.dart';
import 'german_tokenizer.dart';

class LivePrefixComparator {
  /// Evaluates typed learner text against reference text word-by-word in real time.
  /// Correct words/prefixes show as [LiveTokenStatus.correct] (green),
  /// while mismatches show as [LiveTokenStatus.incorrect] (red).
  static List<LiveTokenFeedback> compareLive({
    required String referenceText,
    required String typedText,
    bool strictCase = true,
  }) {
    if (typedText.isEmpty) {
      return const [];
    }

    final expectedWords = GermanTokenizer.extractWords(referenceText);
    
    // Check if the typed input ends with whitespace (meaning the last word is completed)
    final endsWithSpace = RegExp(r'\s+$').hasMatch(typedText);

    // Extract typed words and their order
    final rawTypedMatches = RegExp(r'[a-zA-ZäöüÄÖÜß]+(?:-[a-zA-ZäöüÄÖÜß]+)*', unicode: true)
        .allMatches(typedText)
        .map((m) => m.group(0)!)
        .toList();

    if (rawTypedMatches.isEmpty) {
      return const [];
    }

    final feedbackList = <LiveTokenFeedback>[];

    for (int i = 0; i < rawTypedMatches.length; i++) {
      final typedWord = rawTypedMatches[i];
      final isLastWord = i == rawTypedMatches.length - 1;
      final isCompleted = !isLastWord || endsWithSpace;

      if (i < expectedWords.length) {
        final expectedWord = expectedWords[i];

        if (isCompleted) {
          // Completed word: exact match (or case-insensitive if not strict)
          final matches = strictCase
              ? typedWord == expectedWord
              : typedWord.toLowerCase() == expectedWord.toLowerCase();

          feedbackList.add(LiveTokenFeedback(
            typedText: typedWord,
            status: matches ? LiveTokenStatus.correct : LiveTokenStatus.incorrect,
            isCompleted: true,
          ));
        } else {
          // Incomplete word currently being typed: check if it's a valid prefix of expected
          final isPrefix = strictCase
              ? expectedWord.startsWith(typedWord)
              : expectedWord.toLowerCase().startsWith(typedWord.toLowerCase());

          feedbackList.add(LiveTokenFeedback(
            typedText: typedWord,
            status: isPrefix ? LiveTokenStatus.correct : LiveTokenStatus.incorrect,
            isCompleted: false,
          ));
        }
      } else {
        // Extra word beyond reference length
        feedbackList.add(LiveTokenFeedback(
          typedText: typedWord,
          status: LiveTokenStatus.incorrect,
          isCompleted: isCompleted,
        ));
      }
    }

    return feedbackList;
  }
}
