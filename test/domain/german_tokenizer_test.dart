import 'package:flutter_test/flutter_test.dart';
import 'package:deutschtrainer_android/domain/logic/german_tokenizer.dart';

void main() {
  group('GermanTokenizer', () {
    test('tokenizes German text preserving umlauts and sharp s', () {
      const input = 'Schöne Grüße über die Straße!';
      final words = GermanTokenizer.extractWords(input);

      expect(words, ['Schöne', 'Grüße', 'über', 'die', 'Straße']);
    });

    test('extracts compound words with hyphens', () {
      const input = 'Das Deutsch-Lernen macht Spaß.';
      final words = GermanTokenizer.extractWords(input);

      expect(words, ['Das', 'Deutsch-Lernen', 'macht', 'Spaß']);
    });

    test('separates words from punctuation with token offsets', () {
      const input = 'Hallo, Welt!';
      final tokens = GermanTokenizer.tokenize(input);

      expect(tokens.length, 4);
      expect(tokens[0].cleanWord, 'Hallo');
      expect(tokens[1].punctuation, ',');
      expect(tokens[2].cleanWord, 'Welt');
      expect(tokens[3].punctuation, '!');
    });
  });
}
