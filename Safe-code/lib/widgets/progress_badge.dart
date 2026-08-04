import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  const ProgressBadge({
    super.key,
    required this.completed,
    required this.total,
    required this.stars,
  });

  final int completed;
  final int total;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_special, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Прогресс расследования',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 10),
            Text('$completed из $total сейфов открыто • $stars звезд'),
          ],
        ),
      ),
    );
  }
}
