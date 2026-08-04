import '../models/level.dart';

class CodeValidator {
  const CodeValidator();

  bool isCorrect(Level level, String input) {
    return input == level.correctCode;
  }

  bool hasExpectedLength(Level level, String input) {
    return input.length == level.codeLength;
  }

  int calculateStars({required int mistakes, required int hintsUsed}) {
    final penalties = mistakes + hintsUsed;
    if (penalties == 0) {
      return 3;
    }
    if (penalties == 1) {
      return 2;
    }
    return 1;
  }
}
