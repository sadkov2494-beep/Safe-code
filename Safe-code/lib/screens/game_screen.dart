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
import '../widgets/evidence_dossier_card.dart';
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
    setState(() {
      _input += digit;
      _status = InputStatus.idle;
    });
  }

  void _deleteDigit() {
    if (_input.isEmpty || _isOpen) {
      return;
    }
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
            const SizedBox(height: 18),
            EvidenceDossierCard(
              level: level,
              visualMarks: visualMarks,
              highlightImportantClue: _highlightImportantClue,
            ),
            const SizedBox(height: 18),
            Text(
              'Полное досье ниже',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Эти карточки продублированы в кнопке “Все улики” сверху, чтобы не пропустить важную информацию.',
              style: Theme.of(context).textTheme.bodySmall,
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
