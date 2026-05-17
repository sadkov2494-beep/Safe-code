enum ClueType { mastermind, logic, visual }

class Clue {
  const Clue({
    required this.title,
    required this.description,
    required this.type,
    this.isImportant = false,
  });

  final String title;
  final String description;
  final ClueType type;
  final bool isImportant;
}
