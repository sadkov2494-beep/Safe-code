import '../models/clue.dart';
import '../models/level.dart';
import '../models/panel_mark.dart';

class VisualClueService {
  const VisualClueService();

  Map<String, List<PanelMark>> marksByDigit(Level level) {
    final marks = <String, List<PanelMark>>{};

    for (final clue in level.visualClues) {
      final type = _physicalTypeFor(clue);
      if (type == null) {
        continue;
      }
      final digits = _digitsFor(clue, level, type);

      for (final digit in digits) {
        final mark = PanelMark(digit: digit, type: type, label: clue.title);
        final digitMarks = marks.putIfAbsent(digit, () => []);
        if (!digitMarks.any((existing) => existing.type == type)) {
          digitMarks.add(mark);
        }
      }
    }

    return marks;
  }

  PanelMarkType? _physicalTypeFor(Clue clue) {
    final text = '${clue.title} ${clue.description}'.toLowerCase();
    if (text.contains('отпечат')) {
      return PanelMarkType.fingerprint;
    }
    if (text.contains('тепл') || text.contains('холод')) {
      return PanelMarkType.heat;
    }
    if (text.contains('царап')) {
      return PanelMarkType.scratch;
    }
    if (text.contains('стер') || text.contains('потерт')) {
      return PanelMarkType.worn;
    }
    if (text.contains('пыль') || text.contains('налет')) {
      return PanelMarkType.dust;
    }
    return null;
  }

  Set<String> _digitsFor(Clue clue, Level level, PanelMarkType type) {
    final text = '${clue.title} ${clue.description}';
    final digits = RegExp(
      r'\d',
    ).allMatches(text).map((match) => match.group(0)!).toSet();

    if (digits.isNotEmpty) {
      return digits;
    }

    final code = level.correctCode;
    return switch (type) {
      PanelMarkType.fingerprint => {code[0]},
      PanelMarkType.heat => {code[code.length - 1]},
      PanelMarkType.scratch => {code[code.length ~/ 2]},
      PanelMarkType.worn => code.split('').take(2).toSet(),
      PanelMarkType.dust => {code.contains('0') ? '0' : code[0]},
    };
  }
}
