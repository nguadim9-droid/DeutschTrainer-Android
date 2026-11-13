import 'package:flutter_test/flutter_test.dart';
import 'package:deutschtrainer_android/domain/logic/word_comparator.dart';
import 'package:deutschtrainer_android/domain/models/comparison_result.dart';

void main() {
  group('WordComparator', () {
    test('returns 100% and isPerfect for exact match', () {
      const ref = 'Ich trinke gerne Kaffee.';
      const learner = 'Ich trinke gerne Kaffee.';

      final res = WordComparator.compare(referenceText: ref, learnerText: learner);

      expect(res.isPerfect, true);
      expect(res.accuracyPercentage, 100.0);
      expect(res.exactMatches, 4);
      expect(res.substitutions, 0);
      expect(res.missingWords, 0);
      expect(res.extraWords, 0);
    });

    test('detects case differences according to German noun capitalization rules', () {
      const ref = 'Der Hund schläft.';
      const learner = 'der hund schläft.';

      final res = WordComparator.compare(referenceText: ref, learnerText: learner, strictCase: true);

      expect(res.isPerfect, false);
      expect(res.caseDifferences, 2);
      expect(res.exactMatches, 1);
    });

    test('detects substitutions without shifting subsequent words', () {
      const ref = 'Der Zug fährt nach Berlin heute.';
      const learner = 'Der Bus fährt nach Berlin heute.';

      final res = WordComparator.compare(referenceText: ref, learnerText: learner);

      expect(res.isPerfect, false);
      expect(res.substitutions, 1);
      expect(res.exactMatches, 5);
      final sub = res.tokens.firstWhere((t) => t.status == WordMatchStatus.substitution);
      expect(sub.expectedWord, 'Zug');
      expect(sub.learnerWord, 'Bus');
    });

    test('detects missing words', () {
      const ref = 'Wir lernen heute Deutsch.';
      const learner = 'Wir Deutsch.';

      final res = WordComparator.compare(referenceText: ref, learnerText: learner);

      expect(res.isPerfect, false);
      expect(res.missingWords, 2);
      expect(res.exactMatches, 2);
    });

    test('detects extra words', () {
      const ref = 'Guten Morgen.';
      const learner = 'Guten Morgen mein lieber Freund.';

      final res = WordComparator.compare(referenceText: ref, learnerText: learner);

      expect(res.isPerfect, false);
      expect(res.extraWords, 3);
      expect(res.exactMatches, 2);
    });
  });
}
