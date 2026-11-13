import '../models/sentence.dart';

class SentenceSegmenter {
  static const Set<String> _abbreviations = {
    'z.b', 'd.h', 'bzw', 'usw', 'z.t', 'u.a', 'ca', 'vs',
    'dr', 'prof', 'nr', 'str', 'abb', 'st', 'hr', 'fr',
    'bsp', 'min', 'sek', 'std', 'mio', 'mrd',
  };

  /// Segments German text into sentences, preserving exact character offsets.
  static List<Sentence> segment({
    required String documentId,
    required String text,
  }) {
    if (text.trim().isEmpty) {
      return const [];
    }

    final sentences = <Sentence>[];
    int currentStart = 0;
    int orderIndex = 0;

    // Scan for potential sentence boundaries: ., !, ?, followed by whitespace or EOF
    final boundaryRegex = RegExp(r'([.!?]+)(?:\s+|$)');
    final matches = boundaryRegex.allMatches(text);

    for (final match in matches) {
      final punctuation = match.group(1)!;
      final matchEnd = match.end;
      final candidateSentence = text.substring(currentStart, match.start + punctuation.length).trim();

      // Check if this punctuation was part of an abbreviation
      final wordsBefore = candidateSentence.split(RegExp(r'\s+'));
      final lastWord = wordsBefore.isNotEmpty ? wordsBefore.last.toLowerCase().replaceAll(RegExp(r'[^a-zäöüß.]'), '') : '';

      final isAbbreviation = _abbreviations.any((abbr) =>
          lastWord == abbr ||
          lastWord == '$abbr.' ||
          lastWord.endsWith('.$abbr.'));

      if (isAbbreviation && matchEnd < text.length) {
        // Not a true sentence boundary; continue accumulating
        continue;
      }

      if (candidateSentence.isNotEmpty) {
        final actualStart = text.indexOf(candidateSentence, currentStart);
        final actualEnd = actualStart + candidateSentence.length;

        sentences.add(Sentence(
          id: '$documentId-s$orderIndex',
          documentId: documentId,
          orderIndex: orderIndex,
          referenceText: candidateSentence,
          startOffset: actualStart,
          endOffset: actualEnd,
        ));

        orderIndex++;
      }

      currentStart = matchEnd;
    }

    // Remaining text if no terminal punctuation at the end
    if (currentStart < text.length) {
      final remainder = text.substring(currentStart).trim();
      if (remainder.isNotEmpty) {
        final actualStart = text.indexOf(remainder, currentStart);
        sentences.add(Sentence(
          id: '$documentId-s$orderIndex',
          documentId: documentId,
          orderIndex: orderIndex,
          referenceText: remainder,
          startOffset: actualStart,
          endOffset: actualStart + remainder.length,
        ));
      }
    }

    return sentences;
  }
}
