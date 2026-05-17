import 'package:flutter/material.dart';

import '../models/level.dart';
import '../models/player_progress.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    required this.levelService,
    required this.progressService,
    required this.progress,
    required this.onProgressChanged,
  });

  final LevelService levelService;
  final ProgressService progressService;
  final PlayerProgress progress;
  final Future<void> Function() onProgressChanged;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late PlayerProgress _progress = widget.progress;

  Future<void> _reloadProgress() async {
    final progress = await widget.progressService.loadProgress();
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
    await widget.onProgressChanged();
  }

  @override
  Widget build(BuildContext context) {
    final levels = widget.levelService.levels;
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор уровня')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final unlocked = widget.levelService.isUnlocked(level, _progress);
          final stars = _progress.bestStarsFor(level.id);
          return _LevelTile(
            level: level,
            isUnlocked: unlocked,
            stars: stars,
            onTap: unlocked
                ? () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          level: level,
                          levelService: widget.levelService,
                          progressService: widget.progressService,
                        ),
                      ),
                    );
                    await _reloadProgress();
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  final Level level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final difficulty = switch (level.difficulty) {
      LevelDifficulty.easy => 'Простой',
      LevelDifficulty.medium => 'Средний',
      LevelDifficulty.hard => 'Сложный',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        enabled: isUnlocked,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isUnlocked
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(isUnlocked ? Icons.lock_open : Icons.lock_outline),
        ),
        title: Text('${level.id}. ${level.title}'),
        subtitle: Text(
          '$difficulty • код ${level.codeLength} цифр • ${level.maxAttempts} попыток',
        ),
        trailing: isUnlocked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
