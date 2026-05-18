import '../data/levels.dart';
import '../models/clue.dart';
import '../models/level.dart';
import '../models/player_progress.dart';
import '../models/safe_tool.dart';

class LevelService {
  const LevelService();

  static const dailySafeIdBase = 80000000;

  List<Level> get levels => allLevels;

  Level levelById(int id) {
    return levels.firstWhere((level) => level.id == id);
  }

  Level levelForCollection(int id) {
    if (id >= dailySafeIdBase) {
      return dailySafeFor(_dateFromDailyId(id));
    }
    return levelById(id);
  }

  Level dailySafeFor(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final code = _dailyCode(today);
    final dateLabel = _formatDate(today);
    final sum = code
        .split('')
        .fold<int>(0, (sum, digit) => sum + int.parse(digit));

    return Level(
      id: dailySafeIdBase + today.year * 10000 + today.month * 100 + today.day,
      title: 'Ежедневный сейф $dateLabel',
      difficulty: LevelDifficulty.medium,
      codeLength: code.length,
      correctCode: code,
      maxAttempts: 6,
      logicalClues: [
        Clue(
          title: 'Дневной журнал',
          description: '$code: все четыре цифры верны и стоят на своих местах.',
          type: ClueType.mastermind,
          isImportant: true,
        ),
        Clue(
          title: 'Контрольная сумма',
          description: 'Сумма цифр сегодняшнего сейфа равна $sum.',
          type: ClueType.logic,
        ),
        Clue(
          title: 'Дата выдачи',
          description:
              'Комбинация генерируется один раз в день и меняется после полуночи.',
          type: ClueType.logic,
        ),
      ],
      visualClues: [
        Clue(
          title: 'Свежий след',
          description:
              'Самый яркий отпечаток сегодня совпадает с первой цифрой $code.',
          type: ClueType.visual,
          isImportant: true,
        ),
        Clue(
          title: 'Последний щелчок',
          description:
              'Слабый тепловой след остался на финальной цифре ${code[3]}.',
          type: ClueType.visual,
        ),
      ],
      availableTools: [
        SafeTool.fingerprintScanner,
        SafeTool.thermalViewer,
        SafeTool.analyzer,
      ],
      softHint:
          'Ежедневный журнал уже содержит проверенную дневную комбинацию; сверяйте ее с суммой и следами.',
      solutionExplanation:
          'Ежедневный сейф строится по дате $dateLabel. Журнал дает точный код $code, а сумма $sum и физические следы подтверждают первую и последнюю цифры.',
    );
  }

  bool isUnlocked(Level level, PlayerProgress progress) {
    if (level.id == levels.first.id) {
      return true;
    }
    return progress.isCompleted(level.id - 1);
  }

  Level? nextLevel(Level current) {
    if (current.id >= dailySafeIdBase) {
      return null;
    }
    final index = levels.indexWhere((level) => level.id == current.id);
    if (index == -1 || index == levels.length - 1) {
      return null;
    }
    return levels[index + 1];
  }

  String _dailyCode(DateTime date) {
    var seed = date.year * 10000 + date.month * 100 + date.day;
    final digits = <int>[];
    while (digits.length < 4) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final digit = seed % 10;
      if (!digits.contains(digit)) {
        digits.add(digit);
      }
    }
    return digits.join();
  }

  DateTime _dateFromDailyId(int id) {
    final raw = id - dailySafeIdBase;
    final year = raw ~/ 10000;
    final month = (raw ~/ 100) % 100;
    final day = raw % 100;
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
