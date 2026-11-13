import 'package:flutter_test/flutter_test.dart';
import 'package:deutschtrainer_android/domain/logic/sentence_segmenter.dart';

void main() {
  group('SentenceSegmenter', () {
    test('segments multiple standard German sentences', () {
      const text = 'Das ist der erste Satz. Wie geht es dir? Alles ist wunderbar!';
      final sentences = SentenceSegmenter.segment(documentId: 'doc1', text: text);

      expect(sentences.length, 3);
      expect(sentences[0].referenceText, 'Das ist der erste Satz.');
      expect(sentences[1].referenceText, 'Wie geht es dir?');
      expect(sentences[2].referenceText, 'Alles ist wunderbar!');
    });

    test('does not break sentences on German abbreviations like z.B. and usw.', () {
      const text = 'Wir kaufen viele Früchte, z.B. Äpfel und Birnen. Das schmeckt gut.';
      final sentences = SentenceSegmenter.segment(documentId: 'doc1', text: text);

      expect(sentences.length, 2);
      expect(sentences[0].referenceText, 'Wir kaufen viele Früchte, z.B. Äpfel und Birnen.');
      expect(sentences[1].referenceText, 'Das schmeckt gut.');
    });

    test('preserves exact character offsets', () {
      const text = 'Hallo Welt. Bis morgen.';
      final sentences = SentenceSegmenter.segment(documentId: 'doc1', text: text);

      expect(sentences.length, 2);
      expect(text.substring(sentences[0].startOffset, sentences[0].endOffset), sentences[0].referenceText);
      expect(text.substring(sentences[1].startOffset, sentences[1].endOffset), sentences[1].referenceText);
    });
  });
}
