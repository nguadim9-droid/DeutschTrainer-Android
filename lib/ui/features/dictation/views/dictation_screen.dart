import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/comparison_result.dart';
import '../../../../domain/models/live_token_feedback.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_container.dart';
import '../../../core/widgets/german_quick_chars_bar.dart';
import '../view_models/dictation_view_model.dart';

class DictationScreen extends StatefulWidget {
  const DictationScreen({super.key});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncTextFromViewModel(DictationViewModel vm) {
    if (_textController.text != vm.typedText) {
      _textController.text = vm.typedText;
      _textController.selection = TextSelection.collapsed(offset: vm.typedText.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DictationViewModel>();
    final sentence = vm.currentSentence;

    if (sentence == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diktat-Übung')),
        body: const Center(child: Text('Keine Sätze verfügbar')),
      );
    }

    // Keep text field in sync if reset from ViewModel
    if (vm.typedText.isEmpty && _textController.text.isNotEmpty && vm.comparisonResult == null) {
      _textController.clear();
    }

    final currentNum = vm.currentIndex + 1;
    final totalNum = vm.totalSentences;
    final progress = totalNum > 0 ? currentNum / totalNum : 0.0;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.document?.title ?? 'Diktat-Übung',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Satz $currentNum von $totalNum',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: vm.liveFeedbackEnabled
                ? 'Live-Feedback aktiv (Grün/Rot)'
                : 'Live-Feedback deaktiviert',
            icon: Icon(
              vm.liveFeedbackEnabled ? Icons.bolt : Icons.bolt_outlined,
              color: vm.liveFeedbackEnabled ? AppTheme.successGreen : Colors.grey,
            ),
            onPressed: () => vm.toggleLiveFeedback(!vm.liveFeedbackEnabled),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandPrimary),
            minHeight: 4,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: keyboardHeight + 32,
            ),
            child: AdaptiveContainer(
              maxWidth: 760,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Audio Controls Card
                  _buildAudioCard(context, vm),
                  const SizedBox(height: 16),

                  // Show / Hide Original Sentence Toggle & Reference Banner
                  _buildReferenceSentenceSection(context, vm),
                  const SizedBox(height: 16),

                  // Dictation Input Card
                  _buildInputCard(context, vm),
                  const SizedBox(height: 16),

                  // Live Feedback Chips (Instant Green/Red words)
                  if (vm.liveFeedbackEnabled &&
                      vm.liveTokens.isNotEmpty &&
                      vm.comparisonResult == null)
                    _buildLiveFeedbackChips(context, vm),

                  // Post-Submission Result Card
                  if (vm.comparisonResult != null)
                    _buildResultCard(context, vm, vm.comparisonResult!),

                  const SizedBox(height: 24),

                  // Bottom Action Buttons
                  _buildActionButtons(context, vm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, DictationViewModel vm) {
    final tts = vm.ttsService;
    final isPlaying = tts.isPlaying;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Play / Stop Button
            ElevatedButton.icon(
              onPressed: isPlaying ? vm.stopAudio : vm.playAudio,
              icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
              label: Text(isPlaying ? 'Stop' : 'Anhören'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? AppTheme.errorRed : AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),

            // Speed Selector (0.8x slow / 1.0x normal)
            PopupMenuButton<double>(
              initialValue: tts.speechRate,
              tooltip: 'Geschwindigkeit anpassen',
              onSelected: (rate) => tts.setSpeechRate(rate),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      tts.speechRate <= 0.35
                          ? '0.7x'
                          : (tts.speechRate <= 0.45 ? '0.8x' : '1.0x'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0.35, child: Text('0.7x (Langsam)')),
                const PopupMenuItem(value: 0.45, child: Text('0.8x (Empfohlen)')),
                const PopupMenuItem(value: 0.55, child: Text('1.0x (Normal)')),
              ],
            ),

            const Spacer(),

            // Voice Status Badge
            if (!tts.hasGermanVoice)
              Tooltip(
                message: tts.errorMessage ?? 'Keine deutsche Stimme gefunden',
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.warningAmber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Keine dt. Stimme',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warningAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'de-DE bereit',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSentenceSection(BuildContext context, DictationViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Diktat & Selbstkontrolle:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            OutlinedButton.icon(
              onPressed: vm.toggleReveal,
              icon: Icon(
                vm.isRevealed ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: vm.isRevealed ? AppTheme.brandPrimary : null,
              ),
              label: Text(
                vm.isRevealed ? 'Originalsatz ausblenden' : 'Originalsatz anzeigen',
                style: TextStyle(
                  fontSize: 13,
                  color: vm.isRevealed ? AppTheme.brandPrimary : null,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: vm.isRevealed ? AppTheme.brandLight : null,
              ),
            ),
          ],
        ),

        // Revealed Card
        if (vm.isRevealed && vm.currentSentence != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.brandLight,
              border: Border.all(color: AppTheme.brandSecondary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ORIGINALSATZ (REFERENZ)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.brandPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: vm.toggleReveal,
                      child: const Row(
                        children: [
                          Icon(Icons.close, size: 14, color: AppTheme.brandPrimary),
                          SizedBox(width: 2),
                          Text(
                            'Ausblenden',
                            style: TextStyle(fontSize: 11, color: AppTheme.brandPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  vm.currentSentence!.referenceText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, DictationViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // German Quick Character Bar (ä, ö, ü, ß, Ä, Ö, Ü)
            GermanQuickCharsBar(
              controller: _textController,
              onCharInserted: () => vm.updateTypedText(_textController.text),
            ),
            const SizedBox(height: 14),

            // Text Input Field
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 3,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(fontSize: 18, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Tippen Sie hier, was Sie auf Deutsch hören...',
              ),
              onChanged: (text) => vm.updateTypedText(text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveFeedbackChips(BuildContext context, DictationViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, size: 16, color: AppTheme.successGreen),
              const SizedBox(width: 6),
              Text(
                'Live-Feedback (Echtzeit)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.liveTokens.map((token) {
              final isCorrect = token.status == LiveTokenStatus.correct;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCorrect ? AppTheme.successGreenLight : AppTheme.errorRedLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: 14,
                      color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      token.typedText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, DictationViewModel vm, ComparisonResult res) {
    return Card(
      color: res.isPerfect ? AppTheme.successGreenLight.withOpacity(0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      res.isPerfect ? Icons.stars_rounded : Icons.fact_check_rounded,
                      color: res.isPerfect ? AppTheme.successGreen : AppTheme.brandPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      res.isPerfect ? 'Perfekt geschrieben!' : 'Ergebnis & Auswertung',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: res.isPerfect ? AppTheme.successGreen : null,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: res.accuracyPercentage >= 90
                        ? AppTheme.successGreen
                        : (res.accuracyPercentage >= 60
                            ? AppTheme.warningAmber
                            : AppTheme.errorRed),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${res.accuracyPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Word-by-word diff chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: res.tokens.map((token) {
                switch (token.status) {
                  case WordMatchStatus.exact:
                    return _buildDiffChip(
                      text: token.learnerWord ?? '',
                      color: AppTheme.successGreenLight,
                      borderColor: AppTheme.successGreen,
                      textColor: AppTheme.successGreen,
                      icon: Icons.check,
                    );
                  case WordMatchStatus.caseDifference:
                    return _buildDiffChip(
                      text: '${token.learnerWord} (${token.expectedWord})',
                      color: AppTheme.warningAmberLight,
                      borderColor: AppTheme.warningAmber,
                      textColor: AppTheme.warningAmber,
                      icon: Icons.text_fields,
                    );
                  case WordMatchStatus.substitution:
                    return _buildDiffChip(
                      text: '${token.learnerWord} → ${token.expectedWord}',
                      color: AppTheme.errorRedLight,
                      borderColor: AppTheme.errorRed,
                      textColor: AppTheme.errorRed,
                      icon: Icons.close,
                    );
                  case WordMatchStatus.missing:
                    return _buildDiffChip(
                      text: '[fehlt: ${token.expectedWord}]',
                      color: Colors.grey.shade100,
                      borderColor: Colors.grey.shade400,
                      textColor: Colors.grey.shade700,
                      icon: Icons.remove,
                    );
                  case WordMatchStatus.extra:
                    return _buildDiffChip(
                      text: '[überflüssig: ${token.learnerWord}]',
                      color: AppTheme.errorRedLight,
                      borderColor: AppTheme.errorRed,
                      textColor: AppTheme.errorRed,
                      icon: Icons.add,
                    );
                  case WordMatchStatus.punctuationDifference:
                    return const SizedBox.shrink();
                }
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffChip({
    required String text,
    required Color color,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DictationViewModel vm) {
    final hasResult = vm.comparisonResult != null;
    final isLast = vm.currentIndex >= vm.totalSentences - 1;

    if (!hasResult) {
      return ElevatedButton.icon(
        onPressed: vm.typedText.trim().isEmpty ? null : vm.submit,
        icon: const Icon(Icons.done_all_rounded),
        label: const Text('Prüfen (Absenden)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: vm.retry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Wiederholen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        if (!isLast) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: vm.nextSentence,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Nächster Satz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
