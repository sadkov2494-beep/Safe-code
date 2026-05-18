import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/player_progress.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../widgets/progress_badge.dart';
import 'collection_screen.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class MainMenuScreen extends StatefulWidget {
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
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nextLevel = (widget.progress.completedCount + 1).clamp(
      1,
      widget.levelService.levels.length,
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MenuAtmospherePainter(
                    colorScheme: colorScheme,
                    progress: _pulseController.value,
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  children: [
                    _HeroPanel(
                      pulse: _pulseController.value,
                      nextLevel: nextLevel,
                      totalLevels: widget.levelService.levels.length,
                    ),
                    const SizedBox(height: 16),
                    ProgressBadge(
                      completed: widget.progress.completedCount,
                      total: widget.levelService.levels.length,
                      stars: widget.progress.totalStars,
                    ),
                    const SizedBox(height: 12),
                    _DailyStreakCard(progress: widget.progress),
                    const SizedBox(height: 16),
                    _PrimaryActionCard(
                      completed: widget.progress.completedCount,
                      total: widget.levelService.levels.length,
                      onPlay: _startPlayFlow,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MenuActionTile(
                            icon: Icons.school_outlined,
                            title: 'Обучение',
                            subtitle: 'Журналы и улики',
                            color: const Color(0xFF67E8F9),
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => const TutorialScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MenuActionTile(
                            icon: Icons.collections_bookmark_outlined,
                            title: 'Коллекция',
                            subtitle: 'Открытые сейфы',
                            color: const Color(0xFFFFC857),
                            onTap: _openCollection,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MenuActionTile(
                            icon: Icons.today_outlined,
                            title: 'Daily',
                            subtitle: widget.progress.dailyStreak == 0
                                ? 'Уникальный сейф дня'
                                : 'Серия ${widget.progress.dailyStreak} дн.',
                            color: const Color(0xFF34D399),
                            onTap: _openDailySafe,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MenuActionTile(
                            icon: Icons.settings_outlined,
                            title: 'Настройки',
                            subtitle: 'Тема и звук',
                            color: const Color(0xFFA78BFA),
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(
                                    themeMode: widget.themeMode,
                                    onThemeChanged: widget.onThemeChanged,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Вы аналитик службы восстановления Safe Code: изучайте сервисные журналы панели, физические следы на кнопках и ограничения вместо случайного подбора.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startPlayFlow() async {
    final onboardingCompleted = await widget.progressService
        .loadOnboardingCompleted();
    if (!mounted) {
      return;
    }

    if (!onboardingCompleted && widget.progress.completedCount == 0) {
      final completed = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      if (completed != true || !mounted) {
        return;
      }
      await widget.progressService.saveOnboardingCompleted();
      await _openFirstLevel();
      return;
    }

    await _openLevelSelect();
  }

  Future<void> _openFirstLevel() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          level: widget.levelService.levels.first,
          levelService: widget.levelService,
          progressService: widget.progressService,
        ),
      ),
    );
    await widget.onProgressChanged();
  }

  Future<void> _openLevelSelect() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          levelService: widget.levelService,
          progressService: widget.progressService,
          progress: widget.progress,
          onProgressChanged: widget.onProgressChanged,
        ),
      ),
    );
    await widget.onProgressChanged();
  }

  Future<void> _openDailySafe() async {
    final dailyLevel = widget.levelService.dailySafeFor(DateTime.now());
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          level: dailyLevel,
          levelService: widget.levelService,
          progressService: widget.progressService,
        ),
      ),
    );
    await widget.onProgressChanged();
  }

  Future<void> _openCollection() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          progress: widget.progress,
          levelService: widget.levelService,
        ),
      ),
    );
    await widget.onProgressChanged();
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.pulse,
    required this.nextLevel,
    required this.totalLevels,
  });

  final double pulse;
  final int nextLevel;
  final int totalLevels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D8CFF).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -34, top: -38, child: _VaultDial(pulse: pulse)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 16, color: Color(0xFF67E8F9)),
                    SizedBox(width: 7),
                    Text(
                      'SAFE CODE UNIT',
                      style: TextStyle(
                        color: Color(0xFFE0F2FE),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Код Сейфа',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.96,
                ),
              ),
              Text(
                'Safe Code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF93C5FD),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroChip(
                    icon: Icons.lock_outline,
                    label: 'Следующий сейф $nextLevel/$totalLevels',
                  ),
                  const _HeroChip(
                    icon: Icons.auto_graph,
                    label: 'Логика без перебора',
                  ),
                  const _HeroChip(
                    icon: Icons.fingerprint,
                    label: 'Физические следы',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Сервисная память панели, отпечатки, тепловые следы и журналы попыток складываются в одну детективную задачу.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFBAE6FD)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.completed,
    required this.total,
    required this.onPlay,
  });

  final int completed;
  final int total;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.92),
            const Color(0xFF22D3EE).withValues(alpha: 0.34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: colorScheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed == 0
                      ? 'Начать расследование'
                      : 'Продолжить вскрытие',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Открыто $completed из $total сейфов'),
              ],
            ),
          ),
          FilledButton(onPressed: onPlay, child: const Text('Играть')),
        ],
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard({required this.progress});

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final streak = progress.dailyStreak;
    final best = progress.bestDailyStreak;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF34D399).withValues(alpha: 0.16),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Color(0xFF34D399),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 0
                        ? 'Daily streak еще не начат'
                        : 'Daily streak: $streak ${_dayWord(streak)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    best == 0
                        ? 'Откройте ежедневный сейф, чтобы начать серию.'
                        : 'Лучший рекорд: $best ${_dayWord(best)} • daily-сейфов: ${progress.openedDailySafes}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayWord(int value) {
    if (value % 10 == 1 && value % 100 != 11) {
      return 'день';
    }
    if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) {
      return 'дня';
    }
    return 'дней';
  }
}

class _MenuActionTile extends StatelessWidget {
  const _MenuActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: color.withValues(alpha: 0.22),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultDial extends StatelessWidget {
  const _VaultDial({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pulse * 0.9,
      child: Container(
        width: 142,
        height: 142,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 10,
          ),
        ),
        child: CustomPaint(painter: _VaultDialPainter(pulse: pulse)),
      ),
    );
  }
}

class _VaultDialPainter extends CustomPainter {
  const _VaultDialPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.36);
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.42);
    for (var i = 0; i < 18; i++) {
      final angle = i * 0.349;
      final start = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5D8CFF).withValues(alpha: 0.74);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      pulse * 6.283,
      1.25,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _VaultDialPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

class _MenuAtmospherePainter extends CustomPainter {
  const _MenuAtmospherePainter({
    required this.colorScheme,
    required this.progress,
  });

  final ColorScheme colorScheme;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        colors: [
          colorScheme.surface,
          colorScheme.primaryContainer.withValues(alpha: 0.22),
          colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    _drawGlow(
      canvas,
      size,
      Offset(size.width * (0.2 + progress * 0.12), 80),
      const Color(0xFF5D8CFF),
      150,
    );
    _drawGlow(
      canvas,
      size,
      Offset(size.width * 0.88, size.height * (0.42 + progress * 0.08)),
      const Color(0xFF22D3EE),
      130,
    );
    _drawGlow(
      canvas,
      size,
      Offset(size.width * 0.1, size.height * 0.82),
      const Color(0xFFA78BFA),
      120,
    );

    final linePaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawGlow(
    Canvas canvas,
    Size size,
    Offset center,
    Color color,
    double radius,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.22), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MenuAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme;
  }
}
