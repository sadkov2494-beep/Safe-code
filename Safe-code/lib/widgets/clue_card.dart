import 'package:flutter/material.dart';

import '../models/clue.dart';

class ClueCard extends StatelessWidget {
  const ClueCard({super.key, required this.clue, this.highlighted = false});

  final Clue clue;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, label) = switch (clue.type) {
      ClueType.mastermind => (Icons.fact_check_outlined, 'Журнал'),
      ClueType.logic => (Icons.rule_folder_outlined, 'Логика'),
      ClueType.visual => (Icons.visibility_outlined, 'Улика'),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? colorScheme.primary : colorScheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.18)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: ListTile(
        leading: Icon(icon, color: highlighted ? colorScheme.primary : null),
        title: Text(clue.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$label • ${clue.description}'),
        ),
      ),
    );
  }
}
