import 'package:flutter_test/flutter_test.dart';
import 'package:safe_code/data/levels.dart';
import 'package:safe_code/services/code_validator.dart';

void main() {
  group('CodeValidator', () {
    const validator = CodeValidator();
    final level = allLevels.first;

    test('accepts the correct code', () {
      expect(validator.isCorrect(level, level.correctCode), isTrue);
    });

    test('rejects an incorrect code', () {
      expect(validator.isCorrect(level, '000'), isFalse);
    });

    test('calculates stars from mistakes and hints', () {
      expect(validator.calculateStars(mistakes: 0, hintsUsed: 0), 3);
      expect(validator.calculateStars(mistakes: 1, hintsUsed: 0), 2);
      expect(validator.calculateStars(mistakes: 0, hintsUsed: 1), 2);
      expect(validator.calculateStars(mistakes: 2, hintsUsed: 1), 1);
    });
  });
}
