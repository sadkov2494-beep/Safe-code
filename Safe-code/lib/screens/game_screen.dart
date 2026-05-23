import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/level.dart';
import '../models/notebook_entry.dart';
import '../models/safe_tool.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/code_validator.dart';
import '../services/hint_service.dart';
import '../services/level_service.dart';
import '../services/safe_scene_service.dart';
import '../services/level_visual_theme_service.dart';
import '../services/progress_service.dart';
import '../services/visual_clue_service.dart';
import '../widgets/clue_card.dart';
import '../widgets/keypad_widget.dart';
import '../widgets/scene_backdrop.dart';
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
  final _audioService = const AudioService();
  final _visualClueService = const VisualClueService();
  final _visualThemeService = const LevelVisualThemeService();
  final _sceneService = const SafeSceneService();
  final _noteController = TextEditingController();

  String _input = '';
  int _mistakes = 0;
  int _hintsUsed = 0;
  late int _attemptsLeft = widget.level.maxAttempts;
  bool _isOpen = false;
  bool _highlightImportantClue = false;
  NotebookEntry _notebook = NotebookEntry.empty();
  InputStatus _status = InputStatus.idle;

  @override
  void initState() {
    super.initState();
    unawaited(_audioService.startAmbient());
    _loadNotebook();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNotebook() async {
    final notebook = await widget.progressService.loadNotebook(widget.level.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _notebook = notebook;
      _noteController.text = notebook.note;
    });
  }

  void _addDigit(String digit) {
    if (_input.length >= widget.level.codeLength || _isOpen) {
      return;
    }
    unawaited(_audioService.playKeyClick());
    setState(() {
      _input += digit;
      _status = InputStatus.idle;
    });
  }

  void _deleteDigit() {
    if (_input.isEmpty || _isOpen) {
      return;
    }
    unawaited(_audioService.playBackspace());
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
      await _audioService.playUnlock();
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
    await _audioService.playError();
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
    unawaited(_audioService.playHint());
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
    unawaited(_audioService.playHint());
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
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: _ToolScanSheet(tool: tool, result: result, level: widget.level),
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

  Future<void> _saveNotebook(NotebookEntry entry) async {
    setState(() => _notebook = entry);
    await widget.progressService.saveNotebook(widget.level.id, entry);
  }

  void _showNotebookSheet() {
    var draft = _notebook;
    _noteController.text = draft.note;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Блокнот цифр',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нажимайте на цифру, чтобы менять отметку: возможно, исключено, подтверждено.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(10, (digit) {
                        final mark =
                            draft.digitMarks[digit] ?? DigitMark.unknown;
                        return _DigitNoteChip(
                          digit: digit,
                          mark: mark,
                          onTap: () {
                            final updatedMarks = Map<int, DigitMark>.from(
                              draft.digitMarks,
                            );
                            final nextMark = _nextDigitMark(mark);
                            if (nextMark == DigitMark.unknown) {
                              updatedMarks.remove(digit);
                            } else {
                              updatedMarks[digit] = nextMark;
                            }
                            final updated = draft.copyWith(
                              digitMarks: updatedMarks,
                            );
                            setSheetState(() => draft = updated);
                            _saveNotebook(updated);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Заметки',
                        hintText: 'Например: 4 точно первая, 9 исключить...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final updated = draft.copyWith(note: value);
                        draft = updated;
                        _saveNotebook(updated);
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Закрыть'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DigitMark _nextDigitMark(DigitMark mark) {
    return switch (mark) {
      DigitMark.unknown => DigitMark.candidate,
      DigitMark.candidate => DigitMark.rejected,
      DigitMark.rejected => DigitMark.confirmed,
      DigitMark.confirmed => DigitMark.unknown,
    };
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
                    } else if (mounted) {
                      _showAdUnavailableSnack();
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
                    } else if (mounted) {
                      _showAdUnavailableSnack();
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
    if (!mounted) {
      return;
    }
    if (!ok) {
      _showAdUnavailableSnack();
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

  void _showAdUnavailableSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Реклама сейчас недоступна. Попробуйте еще раз позже.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final visualMarks = _visualClueService.marksByDigit(level);
    final visualTheme = _visualThemeService.themeForLevel(level.id);
    final scene = _sceneService.sceneForLevel(level.id);
    final isDaily = level.id >= LevelService.dailySafeIdBase;
    return Scaffold(
      appBar: AppBar(
        title: Text(isDaily ? level.title : '${level.id}. ${level.title}'),
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
            SceneBackdrop(
              scene: scene,
              badge: isDaily ? 'DAILY' : null,
              child: SafeWidget(
                input: _input,
                codeLength: level.codeLength,
                isOpen: _isOpen,
                status: _status,
                visualTheme: visualTheme,
              ),
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
            _NotebookSummary(notebook: _notebook, onOpen: _showNotebookSheet),
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

class _NotebookSummary extends StatelessWidget {
  const _NotebookSummary({required this.notebook, required this.onOpen});

  final NotebookEntry notebook;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final confirmed = _digitsWithMark(DigitMark.confirmed);
    final candidates = _digitsWithMark(DigitMark.candidate);
    final rejected = _digitsWithMark(DigitMark.rejected);
    final summary = [
      if (confirmed.isNotEmpty) 'точно: ${confirmed.join(', ')}',
      if (candidates.isNotEmpty) 'возможно: ${candidates.join(', ')}',
      if (rejected.isNotEmpty) 'исключено: ${rejected.join(', ')}',
    ].join(' • ');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.edit_note_outlined),
        title: const Text('Блокнот цифр'),
        subtitle: Text(
          summary.isEmpty
              ? 'Отмечайте кандидатов, исключенные и подтвержденные цифры.'
              : summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }

  List<int> _digitsWithMark(DigitMark mark) {
    final digits =
        notebook.digitMarks.entries
            .where((entry) => entry.value == mark)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    return digits;
  }
}

class _DigitNoteChip extends StatelessWidget {
  const _DigitNoteChip({
    required this.digit,
    required this.mark,
    required this.onTap,
  });

  final int digit;
  final DigitMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (mark) {
      DigitMark.unknown => Theme.of(context).colorScheme.outline,
      DigitMark.candidate => Colors.amber,
      DigitMark.rejected => Theme.of(context).colorScheme.error,
      DigitMark.confirmed => Colors.greenAccent,
    };
    final icon = switch (mark) {
      DigitMark.unknown => Icons.circle_outlined,
      DigitMark.candidate => Icons.help_outline,
      DigitMark.rejected => Icons.close,
      DigitMark.confirmed => Icons.check,
    };
    final label = switch (mark) {
      DigitMark.unknown => 'нет',
      DigitMark.candidate => 'возможно',
      DigitMark.rejected => 'исключить',
      DigitMark.confirmed => 'точно',
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withValues(
            alpha: mark == DigitMark.unknown ? 0.08 : 0.16,
          ),
          border: Border.all(color: color.withValues(alpha: 0.38)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$digit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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

class _ToolScanSheet extends StatelessWidget {
  const _ToolScanSheet({
    required this.tool,
    required this.result,
    required this.level,
  });

  final SafeTool tool;
  final ToolResult result;
  final Level level;

  @override
  Widget build(BuildContext context) {
    final accent = _toolAccent(tool);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: accent.withValues(alpha: 0.16),
                ),
                child: Icon(_toolIcon(tool), color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 128,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ToolScanPainter(
                    tool: tool,
                    color: accent,
                    progress: value,
                    code: level.correctCode,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            color: accent.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(Icons.output, color: accent),
              title: const Text('Результат анализа'),
              subtitle: Text(result.message),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  Color _toolAccent(SafeTool tool) {
    return switch (tool) {
      SafeTool.fingerprintScanner => const Color(0xFF67E8F9),
      SafeTool.thermalViewer => const Color(0xFFFF8A3D),
      SafeTool.decryptor => const Color(0xFFA7F3D0),
      SafeTool.analyzer => const Color(0xFFA78BFA),
      SafeTool.stethoscope => const Color(0xFFFFC857),
    };
  }

  IconData _toolIcon(SafeTool tool) {
    return switch (tool) {
      SafeTool.fingerprintScanner => Icons.fingerprint,
      SafeTool.thermalViewer => Icons.thermostat,
      SafeTool.decryptor => Icons.key_off_outlined,
      SafeTool.analyzer => Icons.analytics_outlined,
      SafeTool.stethoscope => Icons.graphic_eq,
    };
  }
}

class _ToolScanPainter extends CustomPainter {
  const _ToolScanPainter({
    required this.tool,
    required this.color,
    required this.progress,
    required this.code,
  });

  final SafeTool tool;
  final Color color;
  final double progress;
  final String code;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.48),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    final scanX = size.width * progress;
    canvas.drawRect(Rect.fromLTWH(scanX - 22, 0, 44, size.height), scanPaint);

    switch (tool) {
      case SafeTool.fingerprintScanner:
        _drawFingerprint(canvas, size);
      case SafeTool.thermalViewer:
        _drawThermal(canvas, size);
      case SafeTool.decryptor:
        _drawDecryptor(canvas, size);
      case SafeTool.analyzer:
      case SafeTool.stethoscope:
        _drawAnalyzer(canvas, size);
    }
  }

  void _drawFingerprint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width * 0.5, size.height * 0.54);
    for (var i = 0; i < 5; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: 34.0 + i * 18,
          height: 44.0 + i * 16,
        ),
        -2.5,
        4.6,
        false,
        paint,
      );
    }
    _drawDigitBadge(canvas, size, code[0]);
  }

  void _drawThermal(Canvas canvas, Size size) {
    for (var i = 0; i < code.length; i++) {
      final digit = code[i];
      final center = Offset(
        size.width * (0.18 + i * 0.18),
        size.height * (0.35 + (i.isEven ? 0.18 : 0.02)),
      );
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: i == code.length - 1 ? 0.72 : 0.28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 36));
      canvas.drawCircle(center, 36, paint);
      _drawSmallText(canvas, center, digit);
    }
  }

  void _drawDecryptor(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 10; i++) {
      final x = 18 + i * ((size.width - 36) / 9);
      final top = size.height * 0.25;
      final bottom = size.height * 0.75;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
      if (!code.contains('$i')) {
        final cross = Paint()
          ..color = Colors.redAccent.withValues(alpha: 0.75)
          ..strokeWidth = 2;
        canvas.drawLine(Offset(x - 6, top + 8), Offset(x + 6, top + 20), cross);
        canvas.drawLine(Offset(x + 6, top + 8), Offset(x - 6, top + 20), cross);
      }
    }
  }

  void _drawAnalyzer(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.68)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(size.width * 0.12, size.height * 0.72),
      Offset(size.width * 0.3, size.height * 0.42),
      Offset(size.width * 0.48, size.height * 0.62),
      Offset(size.width * 0.68, size.height * 0.28),
      Offset(size.width * 0.88, size.height * 0.46),
    ];
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = color);
    }
  }

  void _drawDigitBadge(Canvas canvas, Size size, String digit) {
    final center = Offset(size.width * 0.82, size.height * 0.28);
    canvas.drawCircle(
      center,
      22,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    _drawSmallText(canvas, center, digit, fontSize: 20);
  }

  void _drawSmallText(
    Canvas canvas,
    Offset center,
    String text, {
    double fontSize = 13,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ToolScanPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tool != tool ||
        oldDelegate.color != color ||
        oldDelegate.code != code;
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
                unawaited(const AudioService().playHint());
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
