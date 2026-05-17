import 'package:flutter/material.dart';

import '../models/clue.dart';
import '../models/level.dart';
import '../models/panel_mark.dart';
import 'clue_card.dart';

class EvidenceDossierCard extends StatelessWidget {
  const EvidenceDossierCard({
    super.key,
    required this.level,
    required this.visualMarks,
    required this.highlightImportantClue,
  });

  final Level level;
  final Map<String, List<PanelMark>> visualMarks;
  final bool highlightImportantClue;

  @override
  Widget build(BuildContext context) {
    final important = level.logicalClues.firstWhere(
      (clue) => clue.isImportant,
      orElse: () => level.logicalClues.first,
    );
    final visual = level.visualClues.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Досье уровня',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllClues(context),
                  child: const Text('Все улики'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _LegendBox(),
            const SizedBox(height: 10),
            _InlineClue(clue: important),
            const SizedBox(height: 8),
            _InlineClue(clue: visual),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.rule_folder_outlined,
                  text: '${level.logicalClues.length} лог. подсказки',
                ),
                _InfoChip(
                  icon: Icons.visibility_outlined,
                  text: '${level.visualClues.length} визуальные улики',
                ),
                _InfoChip(
                  icon: Icons.touch_app_outlined,
                  text: 'физические следы на клавишах',
                ),
              ],
            ),
            if (visualMarks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Кнопки с физическими следами: ${visualMarks.keys.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllClues(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.78,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (context, controller) {
              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                children: [
                  Text(
                    'Улики и ограничения',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сервисные логи и ограничения собраны в досье. На цифровой панели помечаются только физические следы: отпечатки, тепло, царапины, потертости и пыль.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  const _LegendBox(),
                  const SizedBox(height: 16),
                  ...level.allClues.map(
                    (clue) => ClueCard(
                      clue: clue,
                      highlighted: highlightImportantClue && clue.isImportant,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LegendBox extends StatelessWidget {
  const _LegendBox();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.memory_outlined, color: colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Легенда: вы аналитик службы восстановления сейфов Safe Code. Журнальные записи сняты из сервисной памяти панели: контроллер хранит обезличенные старые попытки и сообщает только совпадения, без раскрытия кода.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineClue extends StatelessWidget {
  const _InlineClue({required this.clue});

  final Clue clue;

  @override
  Widget build(BuildContext context) {
    final icon = switch (clue.type) {
      ClueType.mastermind => Icons.fact_check_outlined,
      ClueType.logic => Icons.rule_folder_outlined,
      ClueType.visual => Icons.visibility_outlined,
    };
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${clue.title}: ${clue.description}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }
}
