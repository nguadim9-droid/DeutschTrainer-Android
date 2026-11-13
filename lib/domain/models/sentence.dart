class Sentence {
  final String id;
  final String documentId;
  final int orderIndex;
  final String referenceText;
  final int startOffset;
  final int endOffset;

  const Sentence({
    required this.id,
    required this.documentId,
    required this.orderIndex,
    required this.referenceText,
    required this.startOffset,
    required this.endOffset,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'order_index': orderIndex,
      'reference_text': referenceText,
      'start_offset': startOffset,
      'end_offset': endOffset,
    };
  }

  factory Sentence.fromMap(Map<String, dynamic> map) {
    return Sentence(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      orderIndex: map['order_index'] as int,
      referenceText: map['reference_text'] as String,
      startOffset: map['start_offset'] as int,
      endOffset: map['end_offset'] as int,
    );
  }
}
