class Token {
  final String text;
  final String cleanWord;
  final String punctuation;
  final int offset;

  const Token({
    required this.text,
    required this.cleanWord,
    required this.punctuation,
    required this.offset,
  });
}

class GermanTokenizer {
  // Regex that matches German words including umlauts (äöüÄÖÜß) and hyphens within compound words
  static final RegExp _tokenRegex = RegExp(
    r'([a-zA-ZäöüÄÖÜß]+(?:-[a-zA-ZäöüÄÖÜß]+)*)|([^\s\w]+)',
    unicode: true,
  );

  static List<Token> tokenize(String input) {
    final matches = _tokenRegex.allMatches(input);
    final tokens = <Token>[];

    for (final match in matches) {
      final raw = match.group(0)!;
      final wordMatch = match.group(1);
      final punctMatch = match.group(2);

      tokens.add(Token(
        text: raw,
        cleanWord: wordMatch ?? '',
        punctuation: punctMatch ?? '',
        offset: match.start,
      ));
    }

    return tokens;
  }

  /// Extracts clean word tokens (excluding standalone punctuation tokens)
  static List<String> extractWords(String input) {
    final matches = RegExp(r'[a-zA-ZäöüÄÖÜß]+(?:-[a-zA-ZäöüÄÖÜß]+)*', unicode: true).allMatches(input);
    return matches.map((m) => m.group(0)!).toList();
  }
}
