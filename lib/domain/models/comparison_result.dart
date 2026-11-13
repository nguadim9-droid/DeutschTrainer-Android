enum WordMatchStatus {
  exact,
  substitution,
  missing,
  extra,
  caseDifference,
  punctuationDifference,
}

class WordDiffToken {
  final WordMatchStatus status;
  final String? expectedWord;
  final String? learnerWord;
  final String? expectedPunctuation;
  final String? learnerPunctuation;

  const WordDiffToken({
    required this.status,
    this.expectedWord,
    this.learnerWord,
    this.expectedPunctuation,
    this.learnerPunctuation,
  });
}

class ComparisonResult {
  final List<WordDiffToken> tokens;
  final int totalExpectedWords;
  final int exactMatches;
  final int caseDifferences;
  final int substitutions;
  final int missingWords;
  final int extraWords;
  final double accuracyPercentage;
  final bool isPerfect;

  const ComparisonResult({
    required this.tokens,
    required this.totalExpectedWords,
    required this.exactMatches,
    required this.caseDifferences,
    required this.substitutions,
    required this.missingWords,
    required this.extraWords,
    required this.accuracyPercentage,
    required this.isPerfect,
  });
}
