import 'clue.dart';
import 'puzzle_archetype.dart';
import 'safe_tool.dart';

enum LevelDifficulty { easy, medium, hard }

class Level {
  const Level({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.codeLength,
    required this.correctCode,
    required this.maxAttempts,
    required this.logicalClues,
    required this.visualClues,
    required this.availableTools,
    required this.softHint,
    required this.solutionExplanation,
    required this.archetype,
    this.isBoss = false,
    this.difficultyRating = 0,
  });

  final int id;
  final String title;
  final LevelDifficulty difficulty;
  final int codeLength;
  final String correctCode;
  final int maxAttempts;
  final List<Clue> logicalClues;
  final List<Clue> visualClues;
  final List<SafeTool> availableTools;
  final String softHint;
  final String solutionExplanation;
  final PuzzleArchetype archetype;
  final bool isBoss;
  final int difficultyRating;

  List<Clue> get allClues => [...logicalClues, ...visualClues];

  List<Clue> get reliableLogicalClues =>
      logicalClues.where((clue) => clue.isReliable).toList();
}
