import 'package:flutter/material.dart';

import '../models/level.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.rating,
    required this.maxRating,
    this.compact = false,
  });

  final int rating;
  final int maxRating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final filled = (rating / maxRating * 5).ceil().clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < filled;
        return Padding(
          padding: EdgeInsets.only(right: compact ? 2 : 4),
          child: Icon(
            active ? Icons.whatshot : Icons.whatshot_outlined,
            size: compact ? 14 : 16,
            color: active ? _colorForRating(filled) : Colors.white24,
          ),
        );
      }),
    );
  }

  Color _colorForRating(int filled) {
    if (filled <= 2) {
      return const Color(0xFF67E8F9);
    }
    if (filled <= 3) {
      return const Color(0xFFFFC857);
    }
    return const Color(0xFFA78BFA);
  }
}

class PuzzleTypeChip extends StatelessWidget {
  const PuzzleTypeChip({super.key, required this.label, this.accent});

  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

int difficultyRatingFor(Level level) {
  return level.difficultyRating > 0 ? level.difficultyRating : level.id;
}
