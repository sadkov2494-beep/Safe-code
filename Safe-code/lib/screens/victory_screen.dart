import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/ad_service.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import 'game_screen.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({
    super.key,
    required this.level,
    required this.stars,
    required this.nextLevel,
    required this.levelService,
    required this.progressService,
    this.wasSkipped = false,
  });

  final Level level;
  final int stars;
  final Level? nextLevel;
  final LevelService levelService;
  final ProgressService progressService;
  final bool wasSkipped;

  static const _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Сейф открыт'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 18),
            Icon(
              wasSkipped ? Icons.fast_forward : Icons.lock_open,
              color: Colors.greenAccent,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              wasSkipped ? 'Уровень пропущен' : 'Код подтвержден',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 34,
                );
              }),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Код: ${level.correctCode}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(height: 26),
                    Text(
                      'Объяснение решения',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(level.solutionExplanation),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (nextLevel != null)
              FilledButton.icon(
                icon: const Icon(Icons.navigate_next),
                label: const Text('Следующий сейф'),
                onPressed: () async {
                  await _adService.showInterstitialAd(
                    InterstitialAdPlacement.betweenLevels,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushReplacement<void, void>(
                    MaterialPageRoute(
                      builder: (_) => GameScreen(
                        level: nextLevel!,
                        levelService: levelService,
                        progressService: progressService,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Переиграть'),
              onPressed: () {
                Navigator.of(context).pushReplacement<void, void>(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      level: level,
                      levelService: levelService,
                      progressService: progressService,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('К списку уровней'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
