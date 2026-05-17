import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/level.dart';
import '../models/safe_tool.dart';
import '../services/ad_service.dart';
import '../services/code_validator.dart';
import '../services/hint_service.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../services/visual_clue_service.dart';
import '../widgets/clue_card.dart';
import '../widgets/keypad_widget.dart';
import '../widgets/safe_widget.dart';
import '../widgets/tool_panel.dart';
import 'victory_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.level,
    required this.levelService,
    required this.progressService,
  });

  final Level level;
  final LevelService levelService;
  final ProgressService progressService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _validator = const CodeValidator();
  final _hintService = const HintService();
  final _adService = const AdService();
  final _visualClueService = const VisualClueService();

  String _input = '';
  int _mistakes = 0;
  int _hintsUsed = 0;
  late int _attemptsLeft = widget.level.maxAttempts;
  bool _isOpen = false;
  bool _highlightImportantClue = false;
  InputStatus _status = InputStatus.idle;

  void _addDigit(String digit) {
    if (_input.length >= widget.level.codeLength || _isOpen) {
      return;
    }
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _input += digit;
      _status = InputStatus.idle;
    });
  }

  void _deleteDigit() {
    if (_input.isEmpty || _isOpen) {
      return;
    }
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _status = InputStatus.idle;
    });
  }

  Future<void> _submit() async {
    if (!_validator.hasExpectedLength(widget.level, _input) || _isOpen) {
      return;
    }

    if (_validator.isCorrect(widget.level, _input)) {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
      final stars = _validator.calculateStars(
        mistakes: _mistakes,
        hintsUsed: _hintsUsed,
      );
      setState(() {
        _status = InputStatus.correct;
        _isOpen = true;
      });
      await widget.progressService.saveLevelResult(
        levelId: widget.level.id,
        stars: stars,
      );
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) => VictoryScreen(
            level: widget.level,
            stars: stars,
            nextLevel: widget.levelService.nextLevel(widget.level),
            levelService: widget.levelService,
            progressService: widget.progressService,
          ),
        ),
      );
      return;
    }

    await HapticFeedback.vibrate();
    await SystemSound.play(SystemSoundType.alert);
    setState(() {
      _mistakes++;
      _attemptsLeft--;
      _input = '';
      _status = InputStatus.wrong;
    });
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _attemptsLeft > 0
              ? 'Код не подошел. Осталось попыток: $_attemptsLeft.'
              : 'Попытки закончились. Можно получить еще одну за рекламу-заглушку.',
        ),
      ),
    );
  }

  void _showSoftHint() {
    SystemSound.play(SystemSoundType.click);
    setState(() => _hintsUsed++);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Мягкая подсказка'),
        content: Text(_hintService.softHintFor(widget.level)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _useTool(SafeTool tool) {
    SystemSound.play(SystemSoundType.click);
    if (tool == SafeTool.stethoscope) {
      _showStethoscopeTool();
      return;
    }
    final result = _hintService.useTool(widget.level, tool);
    setState(() {
      _hintsUsed++;
      if (tool == SafeTool.analyzer) {
        _highlightImportantClue = true;
      }
    });
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.title),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showStethoscopeTool() {
    setState(() => _hintsUsed++);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: _StethoscopeMiniGame(
            targetDigit: int.parse(
              widget.level.correctCode[widget.level.correctCode.length ~/ 2],
            ),
          ),
        );
      },
    );
  }

  void _showCluesSheet() {
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
                    'Журналы и ограничения читаются здесь. На клавишах остаются только физические следы.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...widget.level.allClues.map(
                    (clue) => ClueCard(
                      clue: clue,
                      highlighted: _highlightImportantClue && clue.isImportant,
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

  Future<void> _showPauseSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.tips_and_updates_outlined),
                  title: const Text('Дополнительная подсказка за рекламу'),
                  subtitle: const Text(
                    'MVP: реклама не показывается, награда выдается сразу.',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final ok = await _adService.showRewardedAd(
                      RewardedAdPlacement.extraHint,
                    );
                    if (ok && mounted) {
                      _showSoftHint();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Дополнительная попытка за рекламу'),
                  subtitle: const Text(
                    'Заглушка будущей rewarded ads интеграции.',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final ok = await _adService.showRewardedAd(
                      RewardedAdPlacement.extraAttempt,
                    );
                    if (ok && mounted) {
                      setState(() => _attemptsLeft++);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.skip_next_outlined),
                  title: const Text('Пропустить уровень за рекламу'),
                  subtitle: const Text('Засчитывает 1 звезду в MVP.'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _skipLevel();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Выйти к списку уровней'),
                  onTap: () => Navigator.of(context)
                    ..pop()
                    ..pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _skipLevel() async {
    final ok = await _adService.showRewardedAd(RewardedAdPlacement.skipLevel);
    if (!ok || !mounted) {
      return;
    }
    await widget.progressService.saveLevelResult(
      levelId: widget.level.id,
      stars: 1,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(
        builder: (_) => VictoryScreen(
          level: widget.level,
          stars: 1,
          nextLevel: widget.levelService.nextLevel(widget.level),
          levelService: widget.levelService,
          progressService: widget.progressService,
          wasSkipped: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final visualMarks = _visualClueService.marksByDigit(level);
    return Scaffold(
      appBar: AppBar(
        title: Text('${level.id}. ${level.title}'),
        actions: [
          IconButton(
            tooltip: 'Пауза и монетизация',
            icon: const Icon(Icons.pause_circle_outline),
            onPressed: _showPauseSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            SafeWidget(
              input: _input,
              codeLength: level.codeLength,
              isOpen: _isOpen,
              status: _status,
              difficulty: level.difficulty,
            ),
            const SizedBox(height: 10),
            KeypadWidget(
              onDigit: _addDigit,
              onDelete: _deleteDigit,
              onSubmit: _attemptsLeft > 0 ? _submit : () {},
              canSubmit: _input.length == level.codeLength && _attemptsLeft > 0,
              visualMarks: visualMarks,
            ),
            const SizedBox(height: 8),
            Text(
              'На клавишах показаны только физические следы: отпечатки, тепло, царапины, пыль и потертости. Журнальные записи остаются в досье.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _TacticalStrip(
              attemptsLeft: _attemptsLeft,
              maxAttempts: level.maxAttempts,
              mistakes: _mistakes,
              hintsUsed: _hintsUsed,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _showSoftHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Взять подсказку'),
            ),
            const SizedBox(height: 10),
            ToolPanel(tools: level.availableTools, onUseTool: _useTool),
            const SizedBox(height: 14),
            _ClueSectionHeader(
              clueCount: level.allClues.length,
              markedDigits: visualMarks.keys.toList(),
              onOpenSheet: _showCluesSheet,
            ),
            const SizedBox(height: 10),
            ...level.allClues.map(
              (clue) => ClueCard(
                clue: clue,
                highlighted: _highlightImportantClue && clue.isImportant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticalStrip extends StatelessWidget {
  const _TacticalStrip({
    required this.attemptsLeft,
    required this.maxAttempts,
    required this.mistakes,
    required this.hintsUsed,
  });

  final int attemptsLeft;
  final int maxAttempts;
  final int mistakes;
  final int hintsUsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attemptRatio = maxAttempts == 0 ? 0.0 : attemptsLeft / maxAttempts;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _MetricBlock(
                title: 'Попытки',
                value: '$attemptsLeft/$maxAttempts',
                icon: Icons.pin_outlined,
                color: colorScheme.primary,
                progress: attemptRatio,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBlock(
                title: 'Ошибки',
                value: '$mistakes',
                icon: Icons.error_outline,
                color: mistakes == 0 ? Colors.greenAccent : colorScheme.error,
                progress: mistakes == 0
                    ? 0.08
                    : (mistakes / maxAttempts).clamp(0.0, 1.0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBlock(
                title: 'Помощь',
                value: '$hintsUsed',
                icon: Icons.lightbulb_outline,
                color: Colors.amber,
                progress: hintsUsed == 0
                    ? 0.08
                    : (hintsUsed / 3).clamp(0.0, 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClueSectionHeader extends StatelessWidget {
  const _ClueSectionHeader({
    required this.clueCount,
    required this.markedDigits,
    required this.onOpenSheet,
  });

  final int clueCount;
  final List<String> markedDigits;
  final VoidCallback onOpenSheet;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.primary.withValues(alpha: 0.14),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Улики и ограничения',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    markedDigits.isEmpty
                        ? '$clueCount записей в деле'
                        : '$clueCount записей • следы на кнопках ${markedDigits.join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onOpenSheet, child: const Text('Открыть')),
          ],
        ),
      ),
    );
  }
}

class _StethoscopeMiniGame extends StatefulWidget {
  const _StethoscopeMiniGame({required this.targetDigit});

  final int targetDigit;

  @override
  State<_StethoscopeMiniGame> createState() => _StethoscopeMiniGameState();
}

class _StethoscopeMiniGameState extends State<_StethoscopeMiniGame> {
  double _dial = 4;
  bool _locked = false;

  double get _signal {
    final distance = (_dial - widget.targetDigit).abs();
    return (1 - distance / 9).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signal = _signal;
    final signalColor = Color.lerp(
      colorScheme.error,
      Colors.greenAccent,
      signal,
    )!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq, color: signalColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Прослушка замка',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${(signal * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: signalColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Медленно ведите диск по цифрам. Чем выше амплитуда и ярче сигнал, тем ближе цифра к правильной механической отметке.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            height: 112,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              border: Border.all(color: signalColor.withValues(alpha: 0.45)),
            ),
            child: CustomPaint(
              painter: _StethoscopeSignalPainter(
                dial: _dial,
                targetDigit: widget.targetDigit,
                color: signalColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (digit) {
              final selected = _dial.round() == digit;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? signalColor.withValues(alpha: 0.24)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? signalColor : colorScheme.outlineVariant,
                  ),
                ),
                child: Text('$digit'),
              );
            }),
          ),
          Slider(
            value: _dial,
            min: 0,
            max: 9,
            divisions: 9,
            label: '${_dial.round()}',
            onChanged: _locked
                ? null
                : (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _dial = value);
                  },
          ),
          const SizedBox(height: 8),
          if (_locked)
            Card(
              color: signalColor.withValues(alpha: 0.12),
              child: ListTile(
                leading: Icon(Icons.hearing, color: signalColor),
                title: Text(
                  'Сильнейший щелчок около цифры ${widget.targetDigit}',
                ),
                subtitle: const Text(
                  'Эта цифра входит в код. Позиция примерная: ближе к центру комбинации.',
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                SystemSound.play(SystemSoundType.click);
                setState(() => _locked = true);
              },
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Зафиксировать пик сигнала'),
            ),
        ],
      ),
    );
  }
}

class _StethoscopeSignalPainter extends CustomPainter {
  const _StethoscopeSignalPainter({
    required this.dial,
    required this.targetDigit,
    required this.color,
  });

  final double dial;
  final int targetDigit;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var y = 0.0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final distance = (dial - targetDigit).abs();
    final amplitude = (1 - distance / 9).clamp(0.0, 1.0);
    final path = Path();
    const points = 42;
    for (var i = 0; i < points; i++) {
      final x = i * size.width / (points - 1);
      final wave = _wave(i, amplitude);
      final y = size.height * 0.5 - wave * size.height * 0.34;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22 + amplitude * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  double _wave(int index, double amplitude) {
    final pattern = [0.0, 0.35, -0.28, 0.62, -0.5, 0.22, -0.12];
    final base = pattern[index % pattern.length];
    final pulse = index % 5 == 0 ? 0.34 : 0.0;
    return (base + pulse) * (0.2 + amplitude * 0.95);
  }

  @override
  bool shouldRepaint(covariant _StethoscopeSignalPainter oldDelegate) {
    return oldDelegate.dial != dial ||
        oldDelegate.targetDigit != targetDigit ||
        oldDelegate.color != color;
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
