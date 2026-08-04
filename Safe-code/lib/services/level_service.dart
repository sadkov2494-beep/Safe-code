import '../data/levels.dart';
import '../models/clue.dart';
import '../models/level.dart';
import '../models/player_progress.dart';
import '../models/puzzle_archetype.dart';
import '../models/safe_tool.dart';
import 'mastermind_service.dart';

class LevelService {
  const LevelService();

  static const dailySafeIdBase = 80000000;
  static const _mastermind = MastermindService();

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
    final journalA = _dailyJournalGuess(code, today, 1);
    final journalB = _dailyJournalGuess(code, today, 2);
    final descriptionA = _journalDescription(
      journalA,
      _mastermind.score(code: code, guess: journalA),
    );
    final descriptionB = _journalDescription(
      journalB,
      _mastermind.score(code: code, guess: journalB),
    );

    return Level(
      id: dailySafeIdBase + today.year * 10000 + today.month * 100 + today.day,
      title: 'Ежедневный сейф $dateLabel',
      difficulty: LevelDifficulty.medium,
      codeLength: code.length,
      correctCode: code,
      maxAttempts: 5,
      archetype: PuzzleArchetype.allWrongPositions,
      difficultyRating: 55,
      logicalClues: [
        Clue(
          title: 'Журнал $journalA',
          description: descriptionA,
          type: ClueType.mastermind,
          isImportant: true,
        ),
        Clue(
          title: 'Журнал $journalB',
          description: descriptionB,
          type: ClueType.mastermind,
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
              'На панели видны следы нажатий, но без точного порядка цифр.',
          type: ClueType.visual,
        ),
        Clue(
          title: 'Последний щелчок',
          description:
              'Слабый тепловой след остался на одной из крайних клавиш.',
          type: ClueType.visual,
        ),
      ],
      availableTools: [
        SafeTool.fingerprintScanner,
        SafeTool.thermalViewer,
        SafeTool.analyzer,
      ],
      softHint:
          'Цифры верны, но их нужно переставить — сверяйте журналы с суммой и следами.',
      solutionExplanation:
          'Ежедневный сейф строится по дате $dateLabel. Журналы дают только перестановки, а сумма $sum сужает кандидатов до кода $code.',
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

  String _dailyJournalGuess(String code, DateTime date, int variant) {
    final digits = code.split('');
    var seed = date.year * 10000 + date.month * 100 + date.day + variant * 97;
    for (var i = digits.length - 1; i > 0; i--) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final swapIndex = seed % (i + 1);
      final temp = digits[i];
      digits[i] = digits[swapIndex];
      digits[swapIndex] = temp;
    }
    final guess = digits.join();
    return guess == code ? _dailyJournalGuess(code, date, variant + 3) : guess;
  }

  String _journalDescription(String guess, MastermindResult result) {
    final lengthWord = switch (guess.length) {
      3 => 'три',
      4 => 'четыре',
      5 => 'пять',
      _ => '${guess.length}',
    };

    if (result.exactMatches == guess.length) {
      return '$guess: все $lengthWord цифры верны и стоят на своих местах.';
    }
    if (result.exactMatches == 0 &&
        result.totalMatches == guess.length) {
      return '$guess: $lengthWord цифры верны, но стоят не на своих местах.';
    }
    if (result.exactMatches == 1 && result.totalMatches == guess.length) {
      return '$guess: все $lengthWord цифры входят в код, одна стоит на своем месте.';
    }
    if (result.exactMatches == 2 && result.totalMatches == 2) {
      return '$guess: две цифры верны и стоят на своих местах.';
    }
    if (result.exactMatches == 1 && result.totalMatches == 2) {
      return '$guess: две цифры верны, одна стоит на своем месте.';
    }
    if (result.exactMatches == 0 && result.totalMatches == 2) {
      return '$guess: две цифры верны, но стоят не на своих местах.';
    }
    if (result.exactMatches == 0 && result.totalMatches == 1) {
      return '$guess: одна цифра верна, но стоит не на своем месте.';
    }
    if (result.exactMatches == 1 && result.totalMatches == 1) {
      return '$guess: одна цифра верна и стоит на своем месте.';
    }
    return '$guess: $lengthWord цифры верны, но стоят не на своих местах.';
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
