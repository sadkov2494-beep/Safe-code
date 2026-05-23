import 'package:flutter_test/flutter_test.dart';
import 'package:safe_code/models/clue.dart';
import 'package:safe_code/data/levels.dart';
import 'package:safe_code/models/level.dart';
import 'package:safe_code/services/level_visual_theme_service.dart';
import 'package:safe_code/services/safe_scene_service.dart';
import 'package:safe_code/services/level_service.dart';

void main() {
  group('Level catalog', () {
    test('contains 30 levels with unique ids', () {
      final ids = allLevels.map((level) => level.id).toSet();

      expect(allLevels, hasLength(30));
      expect(ids, hasLength(allLevels.length));
    });

    test('each level code has the declared length', () {
      for (final level in allLevels) {
        expect(
          level.correctCode.length,
          level.codeLength,
          reason: 'Level ${level.id} has invalid code length.',
        );
      }
    });

    test('each level has a solution explanation', () {
      for (final level in allLevels) {
        expect(
          level.solutionExplanation.trim(),
          isNotEmpty,
          reason: 'Level ${level.id} has no explanation.',
        );
      }
    });

    test('mastermind journal clues match the answer codes', () {
      final failures = <String>[];

      for (final level in allLevels) {
        for (final clue in level.logicalClues.where(
          (clue) => clue.type == ClueType.mastermind,
        )) {
          final expectation = _parseMastermindExpectation(clue.description);
          final guess = expectation.guess;
          final result = _scoreMastermindGuess(level.correctCode, guess);

          if (result.totalMatches != expectation.totalMatches ||
              result.exactMatches != expectation.exactMatches) {
            failures.add(
              'Level ${level.id} journal "$guess": '
              'expected total/exact ${expectation.totalMatches}/${expectation.exactMatches}, '
              'got ${result.totalMatches}/${result.exactMatches}.',
            );
          }
        }
      }

      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('written logical restrictions match the answer codes', () {
      final failures = <String>[];

      for (final level in allLevels) {
        for (final clue in level.logicalClues.where(
          (clue) => clue.type == ClueType.logic,
        )) {
          final error = _validateLogicRestriction(
            level.correctCode,
            clue.description,
          );
          if (error != null) {
            failures.add('Level ${level.id}: $error');
          }
        }
      }

      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('journal clues and restrictions keep each answer valid', () {
      final failures = <String>[];

      for (final level in allLevels) {
        final candidates = _validCandidatesFor(level);
        if (!candidates.contains(level.correctCode)) {
          failures.add(
            'Level ${level.id}: answer ${level.correctCode} is not a valid candidate.',
          );
        }
      }

      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('each level has a unique visual theme', () {
      const service = LevelVisualThemeService();
      final themeNames = <String>{};
      final modelCodes = <String>{};

      for (final level in allLevels) {
        final theme = service.themeForLevel(level.id);
        themeNames.add(theme.name);
        modelCodes.add(theme.modelCode);
      }

      expect(themeNames, hasLength(allLevels.length));
      expect(modelCodes, hasLength(allLevels.length));
    });

    test('all requested background scenes are assigned across levels', () {
      const service = SafeSceneService();
      final sceneTitles = allLevels
          .map((level) => service.sceneForLevel(level.id).title)
          .toSet();

      expect(
        sceneTitles,
        containsAll(['Архив', 'Серверная', 'Склад', 'Лифт', 'Контейнер']),
      );
    });

    test('daily safe is deterministic for the same date', () {
      const service = LevelService();
      final date = DateTime(2026, 5, 18);
      final first = service.dailySafeFor(date);
      final second = service.dailySafeFor(date);

      expect(first.id, second.id);
      expect(first.correctCode, second.correctCode);
      expect(first.codeLength, 4);
      expect(first.id, greaterThanOrEqualTo(LevelService.dailySafeIdBase));
    });
  });
}

List<String> _validCandidatesFor(Level level) {
  final logicalClues = level.logicalClues;
  final mastermindExpectations = logicalClues
      .where((clue) => clue.type == ClueType.mastermind)
      .map((clue) => _parseMastermindExpectation(clue.description))
      .toList();
  final restrictions = logicalClues
      .where((clue) => clue.type == ClueType.logic)
      .map((clue) => clue.description)
      .toList();
  final candidates = <String>[];

  void build(String prefix) {
    if (prefix.length == level.codeLength) {
      final journalsMatch = mastermindExpectations.every((expectation) {
        final result = _scoreMastermindGuess(prefix, expectation.guess);
        return result.totalMatches == expectation.totalMatches &&
            result.exactMatches == expectation.exactMatches;
      });
      if (!journalsMatch) {
        return;
      }
      final restrictionsMatch = restrictions.every(
        (restriction) => _validateLogicRestriction(prefix, restriction) == null,
      );
      if (restrictionsMatch) {
        candidates.add(prefix);
      }
      return;
    }

    for (var digit = 0; digit <= 9; digit++) {
      build('$prefix$digit');
    }
  }

  build('');
  return candidates;
}

String? _validateLogicRestriction(String code, String description) {
  final digits = code.split('').map(int.parse).toList();
  final sum = digits.fold<int>(0, (total, digit) => total + digit);
  final evenCount = digits.where((digit) => digit.isEven).length;
  final nonZeroEvenCount = digits
      .where((digit) => digit != 0 && digit.isEven)
      .length;
  final oddCount = digits.where((digit) => digit.isOdd).length;
  final zeroCount = digits.where((digit) => digit == 0).length;
  final uniqueDigits = digits.toSet().length == digits.length;

  bool fail(bool condition) => !condition;

  if (description.contains('Цифры не повторяются') ||
      description.contains('цифры не повторяются')) {
    if (fail(uniqueDigits)) {
      return '"$description" failed for $code: digits repeat.';
    }
  }
  if (description.contains('соседние цифры не отличаются на 1')) {
    final ok = _adjacentPairs(
      digits,
    ).every((pair) => (pair.$1 - pair.$2).abs() != 1);
    if (fail(ok)) {
      return '"$description" failed for $code: adjacent digits differ by 1.';
    }
  }

  final sumMatch =
      RegExp(r'сумм[аы] цифр равна (\d+)').firstMatch(description) ??
      RegExp(r'сумма равна (\d+)').firstMatch(description);
  if (sumMatch != null) {
    final expected = int.parse(sumMatch.group(1)!);
    if (fail(sum == expected)) {
      return '"$description" failed for $code: sum is $sum.';
    }
  }

  if (description.contains('Последняя цифра больше первой')) {
    if (fail(digits.last > digits.first)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Последняя цифра меньше первой')) {
    if (fail(digits.last < digits.first)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Последняя цифра больше второй')) {
    if (fail(digits.last > digits[1])) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('последняя больше первой')) {
    if (fail(digits.last > digits.first)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('последняя цифра четная')) {
    if (fail(digits.last.isEven)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Последняя цифра нечетная')) {
    if (fail(digits.last.isOdd)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Первая цифра четная')) {
    if (fail(digits.first.isEven)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Первая цифра нечетная')) {
    if (fail(digits.first.isOdd)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('середина равна нулю')) {
    if (fail(digits[digits.length ~/ 2] == 0)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('средняя цифра ровно вдвое меньше первой')) {
    if (fail(digits[1] * 2 == digits.first)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Средняя цифра равна сумме крайних минус 2')) {
    if (fail(digits[1] == digits.first + digits.last - 2)) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Код содержит ровно две нечетные цифры') ||
      description.contains('Ровно две цифры нечетные')) {
    if (fail(oddCount == 2)) {
      return '"$description" failed for $code: odd count is $oddCount.';
    }
  }
  if (description.contains('Код содержит ровно три четные цифры')) {
    if (fail(evenCount == 3)) {
      return '"$description" failed for $code: even count is $evenCount.';
    }
  }
  if (description.contains('Код содержит три ненулевые четные цифры') ||
      description.contains('В коде три ненулевые четные цифры')) {
    if (fail(nonZeroEvenCount == 3)) {
      return '"$description" failed for $code: non-zero even count is $nonZeroEvenCount.';
    }
  }
  if (description.contains('в коде один ноль') ||
      description.contains('один ноль')) {
    if (fail(zeroCount == 1)) {
      return '"$description" failed for $code: zero count is $zeroCount.';
    }
  }
  if (description.contains('Все цифры кода нечетные')) {
    if (fail(oddCount == digits.length)) {
      return '"$description" failed for $code: odd count is $oddCount.';
    }
  }
  if (description.contains('Цифры идут по возрастанию')) {
    if (fail(_adjacentPairs(digits).every((pair) => pair.$1 < pair.$2))) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Цифры идут по убыванию до последней пары')) {
    if (fail(_adjacentPairs(digits).every((pair) => pair.$1 > pair.$2))) {
      return '"$description" failed for $code.';
    }
  }
  if (description.contains('Цифры идут не по порядку')) {
    final ascending = _adjacentPairs(digits).every((pair) => pair.$1 < pair.$2);
    final descending = _adjacentPairs(
      digits,
    ).every((pair) => pair.$1 > pair.$2);
    if (fail(!ascending && !descending)) {
      return '"$description" failed for $code.';
    }
  }

  return null;
}

Iterable<(int, int)> _adjacentPairs(List<int> digits) sync* {
  for (var index = 0; index < digits.length - 1; index++) {
    yield (digits[index], digits[index + 1]);
  }
}

({String guess, int totalMatches, int exactMatches})
_parseMastermindExpectation(String description) {
  final guess = RegExp(r'^\d+').firstMatch(description)!.group(0)!;

  if (description.contains('ни одной верной цифры')) {
    return (guess: guess, totalMatches: 0, exactMatches: 0);
  }
  if (description.contains('все три цифры верны') ||
      description.contains('все четыре цифры верны') ||
      description.contains('все пять цифр верны')) {
    return (
      guess: guess,
      totalMatches: guess.length,
      exactMatches: guess.length,
    );
  }
  if (description.contains('все три цифры входят') &&
      description.contains('одна стоит')) {
    return (guess: guess, totalMatches: 3, exactMatches: 1);
  }
  if (description.contains('четыре цифры верны и стоят')) {
    return (guess: guess, totalMatches: 4, exactMatches: 4);
  }
  if (description.contains('три цифры верны и стоят')) {
    return (guess: guess, totalMatches: 3, exactMatches: 3);
  }
  if (description.contains('две цифры верны и стоят')) {
    return (guess: guess, totalMatches: 2, exactMatches: 2);
  }
  if (description.contains('одна цифра верна и стоит')) {
    return (guess: guess, totalMatches: 1, exactMatches: 1);
  }
  if (description.contains('две цифры верны, но стоят не')) {
    return (guess: guess, totalMatches: 2, exactMatches: 0);
  }
  if (description.contains('одна цифра верна, но стоит не')) {
    return (guess: guess, totalMatches: 1, exactMatches: 0);
  }
  if (description.contains('две цифры верны, одна стоит')) {
    return (guess: guess, totalMatches: 2, exactMatches: 1);
  }

  throw StateError('Unsupported clue format: $description');
}

({int totalMatches, int exactMatches}) _scoreMastermindGuess(
  String code,
  String guess,
) {
  var exactMatches = 0;
  final codeCounts = <String, int>{};
  final guessCounts = <String, int>{};

  for (var index = 0; index < guess.length; index++) {
    final guessDigit = guess[index];
    if (index < code.length && code[index] == guessDigit) {
      exactMatches++;
    }
    guessCounts[guessDigit] = (guessCounts[guessDigit] ?? 0) + 1;
  }

  for (final digit in code.split('')) {
    codeCounts[digit] = (codeCounts[digit] ?? 0) + 1;
  }

  var totalMatches = 0;
  for (final entry in guessCounts.entries) {
    final codeCount = codeCounts[entry.key] ?? 0;
    totalMatches += entry.value < codeCount ? entry.value : codeCount;
  }

  return (totalMatches: totalMatches, exactMatches: exactMatches);
}
