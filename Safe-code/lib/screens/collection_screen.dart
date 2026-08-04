import 'package:flutter/material.dart';

import '../models/level.dart';
import '../models/player_progress.dart';
import '../services/level_service.dart';
import '../services/level_visual_theme_service.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.progress,
    required this.levelService,
  });

  final PlayerProgress progress;
  final LevelService levelService;

  @override
  Widget build(BuildContext context) {
    final completed = progress.levels.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final achievements = _Achievement.forProgress(progress);

    return Scaffold(
      appBar: AppBar(title: const Text('Коллекция сейфов')),
      body: completed.isEmpty
          ? const _EmptyCollection()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _CollectionHeader(
                  count: completed.length,
                  stars: progress.totalStars,
                  streak: progress.dailyStreak,
                ),
                const SizedBox(height: 14),
                _AchievementShelf(achievements: achievements),
                const SizedBox(height: 14),
                ...completed.map((item) {
                  final level = levelService.levelForCollection(item.levelId);
                  return _CollectedSafeCard(level: level, progress: item);
                }),
              ],
            ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.count,
    required this.stars,
    required this.streak,
  });

  final int count;
  final int stars;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Color(0xFFFFC857),
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Открытые сейфы',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count экспонатов • $stars звезд • daily streak $streak',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool unlocked;

  static List<_Achievement> forProgress(PlayerProgress progress) {
    return [
      _Achievement(
        icon: Icons.lock_open,
        title: 'Первое вскрытие',
        description: 'Открыть любой сейф',
        color: const Color(0xFF67E8F9),
        unlocked: progress.levels.isNotEmpty,
      ),
      _Achievement(
        icon: Icons.star,
        title: 'Чистая работа',
        description: 'Набрать 10 звезд',
        color: const Color(0xFFFFC857),
        unlocked: progress.totalStars >= 10,
      ),
      _Achievement(
        icon: Icons.today,
        title: 'Ежедневный агент',
        description: 'Открыть daily safe',
        color: const Color(0xFF34D399),
        unlocked: progress.openedDailySafes >= 1,
      ),
      _Achievement(
        icon: Icons.local_fire_department,
        title: 'Серия 3 дня',
        description: 'Держать daily streak 3 дня',
        color: const Color(0xFFFB923C),
        unlocked: progress.bestDailyStreak >= 3,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        title: 'Коллекционер',
        description: 'Открыть 10 сейфов',
        color: const Color(0xFFA78BFA),
        unlocked: progress.completedCount >= 10,
      ),
    ];
  }
}

class _AchievementShelf extends StatelessWidget {
  const _AchievementShelf({required this.achievements});

  final List<_Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Достижения',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _AchievementCard(achievement: achievement);
            },
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final color = achievement.unlocked
        ? achievement.color
        : Theme.of(context).colorScheme.outline;
    return Container(
      width: 158,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: achievement.unlocked ? 0.14 : 0.08),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            achievement.unlocked ? achievement.icon : Icons.lock_outline,
            color: color,
          ),
          const Spacer(),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CollectedSafeCard extends StatelessWidget {
  const _CollectedSafeCard({required this.level, required this.progress});

  final Level level;
  final LevelProgress progress;

  @override
  Widget build(BuildContext context) {
    const visualThemeService = LevelVisualThemeService();
    final theme = visualThemeService.themeForLevel(level.id);
    final openedAt = progress.completedAt;
    final openedLabel =
        '${openedAt.day.toString().padLeft(2, '0')}.'
        '${openedAt.month.toString().padLeft(2, '0')}.${openedAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [theme.start, theme.end],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: theme.accent.withValues(alpha: 0.38)),
              ),
              child: Icon(Icons.lock_open, color: theme.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.id >= LevelService.dailySafeIdBase
                        ? 'Ежедневный сейф'
                        : 'Дело ${level.id.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: theme.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    level.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${theme.name} • код ${level.correctCode} • открыт $openedLabel',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: List.generate(3, (index) {
                return Icon(
                  index < progress.bestStars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 19,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 14),
            Text(
              'Коллекция пока пуста',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Откройте первый сейф, и его модель, код, дата открытия и звезды появятся здесь.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
