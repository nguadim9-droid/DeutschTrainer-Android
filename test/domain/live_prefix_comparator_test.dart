import 'package:flutter_test/flutter_test.dart';
import 'package:deutschtrainer_android/domain/logic/live_prefix_comparator.dart';
import 'package:deutschtrainer_android/domain/models/live_token_feedback.dart';

void main() {
  group('LivePrefixComparator', () {
    test('marks partial correct prefix as correct (green)', () {
      const ref = 'Guten Morgen.';
      const typed = 'Gut';

      final feedback = LivePrefixComparator.compareLive(
        referenceText: ref,
        typedText: typed,
      );

      expect(feedback.length, 1);
      expect(feedback[0].typedText, 'Gut');
      expect(feedback[0].status, LiveTokenStatus.correct);
      expect(feedback[0].isCompleted, false);
    });

    test('marks incorrect partial word as incorrect (red)', () {
      const ref = 'Guten Morgen.';
      const typed = 'Gxt';

      final feedback = LivePrefixComparator.compareLive(
        referenceText: ref,
        typedText: typed,
      );

      expect(feedback.length, 1);
      expect(feedback[0].typedText, 'Gxt');
      expect(feedback[0].status, LiveTokenStatus.incorrect);
      expect(feedback[0].isCompleted, false);
    });

    test('evaluates completed words with trailing space', () {
      const ref = 'Guten Morgen wie geht es?';
      const typed = 'Guten Mor '; // "Guten" completed (correct), "Mor" completed by space (incorrect because reference is Morgen)

      final feedback = LivePrefixComparator.compareLive(
        referenceText: ref,
        typedText: typed,
      );

      expect(feedback.length, 2);
      expect(feedback[0].typedText, 'Guten');
      expect(feedback[0].status, LiveTokenStatus.correct);

      expect(feedback[1].typedText, 'Mor');
      expect(feedback[1].status, LiveTokenStatus.incorrect); // not finished matching "Morgen"
    });

    test('respects German umlauts in live prefix matching', () {
      const ref = 'Schöne Grüße!';
      const typed = 'Schö';

      final feedback = LivePrefixComparator.compareLive(
        referenceText: ref,
        typedText: typed,
      );

      expect(feedback.length, 1);
      expect(feedback[0].typedText, 'Schö');
      expect(feedback[0].status, LiveTokenStatus.correct);
    });
  });
}
