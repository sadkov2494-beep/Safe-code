import 'package:flutter_test/flutter_test.dart';
import 'package:safe_code/models/clue.dart';
import 'package:safe_code/data/levels.dart';
import 'package:safe_code/services/level_visual_theme_service.dart';

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
  });
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
