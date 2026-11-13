import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

class DocumentParserService {
  /// Parses plain text bytes into a decoded string with UTF-8 / Latin-1 fallback.
  static String parseTxtBytes(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      try {
        return latin1.decode(bytes);
      } catch (e) {
        throw FormatException('Konnte Textdatei nicht dekodieren: $e');
      }
    }
  }

  /// Parses Word (.docx) file bytes by extracting and reading word/document.xml.
  static String parseDocxBytes(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.findFile('word/document.xml');

      if (documentFile == null) {
        throw const FormatException('Ungültiges DOCX-Format: word/document.xml nicht gefunden.');
      }

      final xmlContent = utf8.decode(documentFile.content as List<int>);
      
      // Extract text inside <w:t> tags
      final textRegex = RegExp(r'<w:t[^>]*>(.*?)</w:t>');
      final matches = textRegex.allMatches(xmlContent);

      final buffer = StringBuffer();
      for (final match in matches) {
        final text = match.group(1);
        if (text != null) {
          // Decode XML entities if any
          final decoded = text
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              .replaceAll('&quot;', '"')
              .replaceAll('&apos;', "'");
          buffer.write(decoded);
          buffer.write(' ');
        }
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) {
        throw const FormatException('Das DOCX-Dokument enthält keinen lesbaren Text.');
      }
      return result;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Fehler beim Lesen der DOCX-Datei: $e');
    }
  }
}
