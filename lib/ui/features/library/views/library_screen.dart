import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/dictation_repository.dart';
import '../../../../domain/models/document.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_container.dart';
import '../../dictation/view_models/dictation_view_model.dart';
import '../../dictation/views/dictation_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DictationRepository _repository = DictationRepository();
  List<Document> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = await _repository.loadDocuments();
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _openDictation(Document doc) {
    context.read<DictationViewModel>().startSession(doc);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DictationScreen()),
    );
  }

  void _showAddTextDialog() {
    final titleController = TextEditingController();
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neuen Text importieren'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titel (z.B. Lektion 1)',
                    hintText: 'Name der Übung...',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Deutscher Text',
                    hintText: 'Fügen Sie hier deutsche Sätze ein...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              final title = titleController.text.trim().isEmpty
                  ? 'Eigener Text'
                  : titleController.text.trim();

              if (text.isNotEmpty) {
                final bytes = Uri.encodeComponent(text).codeUnits;
                await _repository.importDocument(
                  filename: '$title.txt',
                  bytes: Uint8List.fromList(bytes),
                );
                if (mounted) {
                  Navigator.of(ctx).pop();
                  _loadDocuments();
                }
              }
            },
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.record_voice_over, color: AppTheme.brandPrimary, size: 26),
            SizedBox(width: 10),
            Text('DeutschTrainer Mobile'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Neuen Text hinzufügen',
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddTextDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: _loadDocuments,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: AdaptiveContainer(
                      maxWidth: 800,
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome & Instructions Banner
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.brandPrimary, AppTheme.brandSecondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hören & Schreiben (Diktat)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Wählen Sie eine Lektion aus. Hören Sie sich den deutschen Satz an und tippen Sie ihn ein. Mit Live-Feedback in Echtzeit (Grün/Rot) und der Möglichkeit, den Originalsatz jederzeit einzusehen.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Verfügbare Lektionen',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${_documents.length} Dokument(e)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Document cards list
                          ..._documents.map((doc) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                child: InkWell(
                                  onTap: () => _openDictation(doc),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.brandLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.hearing_rounded,
                                            color: AppTheme.brandPrimary,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doc.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${doc.sentences.length} deutsche Sätze · ${doc.fileType.toUpperCase()}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTextDialog,
        icon: const Icon(Icons.add),
        label: const Text('Text hinzufügen'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
