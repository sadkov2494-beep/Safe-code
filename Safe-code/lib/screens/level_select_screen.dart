import 'package:flutter/material.dart';

import '../models/level.dart';
import '../models/player_progress.dart';
import '../services/level_service.dart';
import '../services/level_visual_theme_service.dart';
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
  final _visualThemeService = const LevelVisualThemeService();

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
    final groups = [
      _CaseChapter(
        title: 'Глава I: Архивные сейфы',
        subtitle: 'Обучающие дела с короткими кодами',
        intro:
            'Старые архивные сейфы учат базовому правилу: каждая запись журнала - это улика, а не подсказка для перебора.',
        difficulty: LevelDifficulty.easy,
        accent: const Color(0xFF67E8F9),
        icon: Icons.inventory_2_outlined,
      ),
      _CaseChapter(
        title: 'Глава II: Сервисные панели',
        subtitle: 'Больше журналов и перекрестных ограничений',
        intro:
            'Панели из серверных и складских зон смешивают следы, контрольные суммы и позиционные ограничения.',
        difficulty: LevelDifficulty.medium,
        accent: const Color(0xFFFFC857),
        icon: Icons.dns_outlined,
      ),
      _CaseChapter(
        title: 'Глава III: Омега-замки',
        subtitle: 'Сложные дела с плотной логикой',
        intro:
            'Финальные замки требуют вести записи: исключайте лишнее, фиксируйте подтвержденные цифры и проверяйте каждую гипотезу.',
        difficulty: LevelDifficulty.hard,
        accent: const Color(0xFFA78BFA),
        icon: Icons.security_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Архив дел')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ArchiveHeader(
            completed: _progress.completedCount,
            total: levels.length,
            stars: _progress.totalStars,
          ),
          const SizedBox(height: 16),
          for (final chapter in groups) ...[
            _ChapterHeader(
              chapter: chapter,
              completed: levels
                  .where(
                    (level) =>
                        level.difficulty == chapter.difficulty &&
                        _progress.isCompleted(level.id),
                  )
                  .length,
              total: levels
                  .where((level) => level.difficulty == chapter.difficulty)
                  .length,
            ),
            const SizedBox(height: 10),
            ...levels
                .where((level) => level.difficulty == chapter.difficulty)
                .map((level) {
                  final unlocked = widget.levelService.isUnlocked(
                    level,
                    _progress,
                  );
                  final stars = _progress.bestStarsFor(level.id);
                  final visualTheme = _visualThemeService.themeForLevel(
                    level.id,
                  );
                  return _CaseFileTile(
                    level: level,
                    isUnlocked: unlocked,
                    stars: stars,
                    accent: visualTheme.accent,
                    safeStyleName: visualTheme.name,
                    pattern: visualTheme.pattern.name,
                    onTap: unlocked ? () => _openLevel(level) : null,
                  );
                }),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _openLevel(Level level) async {
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
}

class _CaseChapter {
  const _CaseChapter({
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.difficulty,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String intro;
  final LevelDifficulty difficulty;
  final Color accent;
  final IconData icon;
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({
    required this.completed,
    required this.total,
    required this.stars,
  });

  final int completed;
  final int total;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_special, color: Color(0xFF67E8F9)),
              const SizedBox(width: 10),
              Text(
                'Safe Code Case Archive',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: const Color(0xFF67E8F9),
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completed/$total дел закрыто • $stars звезд',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.chapter,
    required this.completed,
    required this.total,
  });

  final _CaseChapter chapter;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: chapter.accent.withValues(alpha: 0.09),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: chapter.accent.withValues(alpha: 0.16),
              ),
              child: Icon(chapter.icon, color: chapter.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${chapter.subtitle} • $completed/$total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: chapter.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(chapter.intro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseFileTile extends StatelessWidget {
  const _CaseFileTile({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.accent,
    required this.safeStyleName,
    required this.pattern,
    required this.onTap,
  });

  final Level level;
  final bool isUnlocked;
  final int stars;
  final Color accent;
  final String safeStyleName;
  final String pattern;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isUnlocked
                      ? accent.withValues(alpha: 0.16)
                      : colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isUnlocked
                        ? accent.withValues(alpha: 0.32)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock_outline,
                  color: isUnlocked ? accent : colorScheme.outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Дело ${level.id.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$safeStyleName • $pattern • код ${level.codeLength} цифр',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 19,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right, color: colorScheme.outline),
                  ],
                )
              else
                Icon(Icons.lock_clock, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
