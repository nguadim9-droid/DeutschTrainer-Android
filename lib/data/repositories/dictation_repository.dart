import 'dart:typed_data';
import '../../domain/logic/sentence_segmenter.dart';
import '../../domain/models/document.dart';
import '../../domain/models/sentence.dart';
import '../services/document_parser_service.dart';
import '../services/local_storage_service.dart';

class DictationRepository {
  /// Loads all documents from SQLite, automatically seeding built-in German starter lessons if empty.
  Future<List<Document>> loadDocuments() async {
    List<Document> docs = await LocalStorageService.getAllDocuments();
    if (docs.isEmpty) {
      await seedStarterLessons();
      docs = await LocalStorageService.getAllDocuments();
    }
    return docs;
  }

  /// Seeds high-quality German starter lessons covering A1, A2, and B1 sentences.
  Future<void> seedStarterLessons() async {
    const starterTitle = 'Alltag & Konversation (Grundkurs)';
    const starterText =
        'Guten Morgen, wie geht es Ihnen heute? '
        'Ich möchte einen Kaffee mit Milch und Zucker bestellen. '
        'Der Zug nach Berlin Hauptbahnhof hat heute zehn Minuten Verspätung. '
        'Können Sie mir bitte sagen, wo die nächste Apotheke ist? '
        'In Deutschland muss man den Müll sorgfältig trennen. '
        'Wir freuen uns sehr auf das gemütliche Wochenende im Schwarzwald.';

    final docId = 'builtin-starter-1';
    final sentences = SentenceSegmenter.segment(
      documentId: docId,
      text: starterText,
    );

    final doc = Document(
      id: docId,
      title: starterTitle,
      sourceFilename: 'grundkurs_alltag.txt',
      fileType: 'built_in',
      rawContent: starterText,
      sentenceCount: sentences.length,
      importedAt: DateTime.now(),
      sentences: sentences,
    );

    await LocalStorageService.insertDocument(doc, sentences);
  }

  /// Imports a new file (.txt or .docx) and segments into German sentences.
  Future<Document> importDocument({
    required String filename,
    required Uint8List bytes,
  }) async {
    final isDocx = filename.toLowerCase().endsWith('.docx');
    final isTxt = filename.toLowerCase().endsWith('.txt');

    if (!isDocx && !isTxt) {
      throw const FormatException('Nur .txt und .docx Dateien werden unterstützt.');
    }

    final rawText = isDocx
        ? DocumentParserService.parseDocxBytes(bytes)
        : DocumentParserService.parseTxtBytes(bytes);

    if (rawText.trim().isEmpty) {
      throw const FormatException('Die Datei enthält keinen Text.');
    }

    final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final title = filename.replaceAll(RegExp(r'\.[^.]+$'), '');

    final sentences = SentenceSegmenter.segment(
      documentId: docId,
      text: rawText,
    );

    if (sentences.isEmpty) {
      throw const FormatException('Keine gültigen Sätze im Dokument gefunden.');
    }

    final doc = Document(
      id: docId,
      title: title,
      sourceFilename: filename,
      fileType: isDocx ? 'docx' : 'txt',
      rawContent: rawText,
      sentenceCount: sentences.length,
      importedAt: DateTime.now(),
      sentences: sentences,
    );

    await LocalStorageService.insertDocument(doc, sentences);
    return doc;
  }

  Future<void> deleteDocument(String id) async {
    await LocalStorageService.deleteDocument(id);
  }
}
