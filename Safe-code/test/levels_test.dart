import 'package:flutter_test/flutter_test.dart';
import 'package:safe_code/data/levels.dart';

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
  });
}
