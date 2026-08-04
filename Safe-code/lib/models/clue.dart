enum ClueType { mastermind, logic, visual }

class Clue {
  const Clue({
    required this.title,
    required this.description,
    required this.type,
    this.isImportant = false,
    this.isReliable = true,
  });

  final String title;
  final String description;
  final ClueType type;
  final bool isImportant;
  final bool isReliable;
}
