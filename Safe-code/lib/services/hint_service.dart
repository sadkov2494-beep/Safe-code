import '../models/level.dart';
import '../models/puzzle_archetype.dart';
import '../models/safe_tool.dart';

class ToolResult {
  const ToolResult({required this.title, required this.message});

  final String title;
  final String message;
}

class HintService {
  const HintService();

  String softHintFor(Level level) {
    if (level.softHint.isNotEmpty) {
      return level.softHint;
    }
    return level.archetype.hint;
  }

  ToolResult useTool(Level level, SafeTool tool) {
    final code = level.correctCode;
    return switch (tool) {
      SafeTool.fingerprintScanner => ToolResult(
        title: tool.title,
        message: 'На панели найден уверенный отпечаток на цифре ${code[0]}.',
      ),
      SafeTool.thermalViewer => ToolResult(
        title: tool.title,
        message:
            'Самый свежий тепловой след рядом с позицией ${code.length}: цифра ${code[code.length - 1]}.',
      ),
      SafeTool.decryptor => ToolResult(
        title: tool.title,
        message: 'Дешифратор исключил цифру ${_firstMissingDigit(code)}.',
      ),
      SafeTool.analyzer => ToolResult(
        title: tool.title,
        message: level.logicalClues
            .firstWhere(
              (clue) => clue.isImportant,
              orElse: () => level.logicalClues.first,
            )
            .description,
      ),
      SafeTool.stethoscope => ToolResult(
        title: tool.title,
        message:
            'Индикатор щелчка усиливается около цифры ${code[code.length ~/ 2]}.',
      ),
    };
  }

  String _firstMissingDigit(String code) {
    for (var digit = 0; digit <= 9; digit++) {
      if (!code.contains('$digit')) {
        return '$digit';
      }
    }
    return '0';
  }
}
