import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../domain/models/document.dart';
import '../../domain/models/sentence.dart';

class LocalStorageService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'deutschtrainer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            source_filename TEXT NOT NULL,
            file_type TEXT NOT NULL,
            raw_content TEXT NOT NULL,
            sentence_count INTEGER NOT NULL,
            imported_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sentences (
            id TEXT PRIMARY KEY,
            document_id TEXT NOT NULL,
            order_index INTEGER NOT NULL,
            reference_text TEXT NOT NULL,
            start_offset INTEGER NOT NULL,
            end_offset INTEGER NOT NULL,
            FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE practice_attempts (
            id TEXT PRIMARY KEY,
            sentence_id TEXT NOT NULL,
            learner_text TEXT NOT NULL,
            is_perfect INTEGER NOT NULL,
            accuracy REAL NOT NULL,
            attempted_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insertDocument(Document doc, List<Sentence> sentences) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'documents',
        doc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final s in sentences) {
        await txn.insert(
          'sentences',
          s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<List<Document>> getAllDocuments() async {
    final db = await database;
    final docsMaps = await db.query('documents', orderBy: 'imported_at DESC');

    final documents = <Document>[];
    for (final map in docsMaps) {
      final docId = map['id'] as String;
      final sentencesMaps = await db.query(
        'sentences',
        where: 'document_id = ?',
        whereArgs: [docId],
        orderBy: 'order_index ASC',
      );

      final sentences = sentencesMaps.map((m) => Sentence.fromMap(m)).toList();
      documents.add(Document.fromMap(map, sentences));
    }

    return documents;
  }

  static Future<void> deleteDocument(String id) async {
    final db = await database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
    await db.delete('sentences', where: 'document_id = ?', whereArgs: [id]);
  }
}
