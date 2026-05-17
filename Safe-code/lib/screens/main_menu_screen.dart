import 'package:flutter/material.dart';

import '../models/player_progress.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../widgets/progress_badge.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.levelService,
    required this.progressService,
    required this.progress,
    required this.themeMode,
    required this.onProgressChanged,
    required this.onThemeChanged,
  });

  final LevelService levelService;
  final ProgressService progressService;
  final PlayerProgress progress;
  final ThemeMode themeMode;
  final Future<void> Function() onProgressChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            Icon(Icons.lock_outline, size: 58, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              'Код Сейфа',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Safe Code',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'Вы аналитик службы восстановления Safe Code: изучайте сервисные журналы панели, физические следы на кнопках и ограничения вместо случайного подбора.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            ProgressBadge(
              completed: progress.completedCount,
              total: levelService.levels.length,
              stars: progress.totalStars,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Выбрать сейф'),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => LevelSelectScreen(
                      levelService: levelService,
                      progressService: progressService,
                      progress: progress,
                      onProgressChanged: onProgressChanged,
                    ),
                  ),
                );
                await onProgressChanged();
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.school_outlined),
              label: const Text('Обучение'),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Ежедневный бонус'),
              onPressed: () async {
                final claimed = await progressService.claimDailyBonus();
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      claimed
                          ? 'Бонус активирован: дополнительная подсказка доступна сегодня.'
                          : 'Бонус уже получен сегодня. Возвращайтесь завтра.',
                    ),
                  ),
                );
                await onProgressChanged();
              },
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Настройки'),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      themeMode: themeMode,
                      onThemeChanged: onThemeChanged,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
