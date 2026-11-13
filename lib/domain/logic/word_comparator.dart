import '../models/comparison_result.dart';
import 'german_tokenizer.dart';

class WordComparator {
  /// Compares reference text against learner attempt deterministically using LCS word alignment.
  static ComparisonResult compare({
    required String referenceText,
    required String learnerText,
    bool strictCase = true,
  }) {
    final expectedTokens = GermanTokenizer.tokenize(referenceText)
        .where((t) => t.cleanWord.isNotEmpty)
        .map((t) => t.cleanWord)
        .toList();

    final learnerTokens = GermanTokenizer.tokenize(learnerText)
        .where((t) => t.cleanWord.isNotEmpty)
        .map((t) => t.cleanWord)
        .toList();

    final n = expectedTokens.length;
    final m = learnerTokens.length;

    // DP table for Longest Common Subsequence of words
    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        final matches = strictCase
            ? expectedTokens[i] == learnerTokens[j]
            : expectedTokens[i].toLowerCase() == learnerTokens[j].toLowerCase();

        if (matches) {
          dp[i + 1][j + 1] = dp[i][j] + 1;
        } else {
          dp[i + 1][j + 1] = dp[i + 1][j] > dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1];
        }
      }
    }

    // Backtrack to build aligned diff tokens
    final diffTokens = <WordDiffToken>[];
    int i = n;
    int j = m;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final exact = expectedTokens[i - 1] == learnerTokens[j - 1];
        final caseDiff = !exact &&
            expectedTokens[i - 1].toLowerCase() == learnerTokens[j - 1].toLowerCase();

        if (exact || (!strictCase && caseDiff)) {
          diffTokens.insert(
            0,
            WordDiffToken(
              status: WordMatchStatus.exact,
              expectedWord: expectedTokens[i - 1],
              learnerWord: learnerTokens[j - 1],
            ),
          );
          i--;
          j--;
          continue;
        } else if (caseDiff) {
          diffTokens.insert(
            0,
            WordDiffToken(
              status: WordMatchStatus.caseDifference,
              expectedWord: expectedTokens[i - 1],
              learnerWord: learnerTokens[j - 1],
            ),
          );
          i--;
          j--;
          continue;
        }
      }

      if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        // Extra word typed by learner
        diffTokens.insert(
          0,
          WordDiffToken(
            status: WordMatchStatus.extra,
            learnerWord: learnerTokens[j - 1],
          ),
        );
        j--;
      } else if (i > 0 && (j == 0 || dp[i][j - 1] < dp[i - 1][j])) {
        // Missing word from expected text
        diffTokens.insert(
          0,
          WordDiffToken(
            status: WordMatchStatus.missing,
            expectedWord: expectedTokens[i - 1],
          ),
        );
        i--;
      }
    }

    // Combine adjacent (missing, extra) pairs into substitutions for clearer feedback
    final consolidatedTokens = <WordDiffToken>[];
    int k = 0;
    while (k < diffTokens.length) {
      if (k + 1 < diffTokens.length &&
          diffTokens[k].status == WordMatchStatus.missing &&
          diffTokens[k + 1].status == WordMatchStatus.extra) {
        consolidatedTokens.add(
          WordDiffToken(
            status: WordMatchStatus.substitution,
            expectedWord: diffTokens[k].expectedWord,
            learnerWord: diffTokens[k + 1].learnerWord,
          ),
        );
        k += 2;
      } else if (k + 1 < diffTokens.length &&
          diffTokens[k].status == WordMatchStatus.extra &&
          diffTokens[k + 1].status == WordMatchStatus.missing) {
        consolidatedTokens.add(
          WordDiffToken(
            status: WordMatchStatus.substitution,
            expectedWord: diffTokens[k + 1].expectedWord,
            learnerWord: diffTokens[k].learnerWord,
          ),
        );
        k += 2;
      } else {
        consolidatedTokens.add(diffTokens[k]);
        k++;
      }
    }

    // Compute statistics
    int exactMatches = 0;
    int caseDifferences = 0;
    int substitutions = 0;
    int missingWords = 0;
    int extraWords = 0;

    for (final token in consolidatedTokens) {
      switch (token.status) {
        case WordMatchStatus.exact:
          exactMatches++;
          break;
        case WordMatchStatus.caseDifference:
          caseDifferences++;
          break;
        case WordMatchStatus.substitution:
          substitutions++;
          break;
        case WordMatchStatus.missing:
          missingWords++;
          break;
        case WordMatchStatus.extra:
          extraWords++;
          break;
        case WordMatchStatus.punctuationDifference:
          break;
      }
    }

    final accuracy = expectedTokens.isEmpty
        ? 100.0
        : ((exactMatches / expectedTokens.length) * 100).clamp(0.0, 100.0);

    final isPerfect = expectedTokens.length == learnerTokens.length &&
        exactMatches == expectedTokens.length &&
        extraWords == 0;

    return ComparisonResult(
      tokens: consolidatedTokens,
      totalExpectedWords: expectedTokens.length,
      exactMatches: exactMatches,
      caseDifferences: caseDifferences,
      substitutions: substitutions,
      missingWords: missingWords,
      extraWords: extraWords,
      accuracyPercentage: double.parse(accuracy.toStringAsFixed(1)),
      isPerfect: isPerfect,
    );
  }
}
