import 'sentence.dart';

class Document {
  final String id;
  final String title;
  final String sourceFilename;
  final String fileType; // 'txt' | 'docx' | 'built_in'
  final String rawContent;
  final int sentenceCount;
  final DateTime importedAt;
  final List<Sentence> sentences;

  const Document({
    required this.id,
    required this.title,
    required this.sourceFilename,
    required this.fileType,
    required this.rawContent,
    required this.sentenceCount,
    required this.importedAt,
    this.sentences = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'source_filename': sourceFilename,
      'file_type': fileType,
      'raw_content': rawContent,
      'sentence_count': sentenceCount,
      'imported_at': importedAt.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map, [List<Sentence> sentences = const []]) {
    return Document(
      id: map['id'] as String,
      title: map['title'] as String,
      sourceFilename: map['source_filename'] as String,
      fileType: map['file_type'] as String,
      rawContent: map['raw_content'] as String,
      sentenceCount: map['sentence_count'] as int,
      importedAt: DateTime.parse(map['imported_at'] as String),
      sentences: sentences,
    );
  }
}
