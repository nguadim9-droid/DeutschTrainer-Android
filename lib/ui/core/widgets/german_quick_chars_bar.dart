import 'package:flutter/material.dart';

class GermanQuickCharsBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCharInserted;

  const GermanQuickCharsBar({
    super.key,
    required this.controller,
    this.onCharInserted,
  });

  static const List<String> _chars = ['ä', 'ö', 'ü', 'ß', 'Ä', 'Ö', 'Ü'];

  void _insertChar(String char) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, char);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + char.length),
      );
    } else {
      controller.text += char;
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }

    onCharInserted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _chars.map((char) {
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: InkWell(
              onTap: () => _insertChar(char),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
