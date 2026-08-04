enum DigitMark { unknown, candidate, rejected, confirmed }

class GuessRecord {
  const GuessRecord({
    required this.guess,
    required this.totalMatches,
    required this.exactMatches,
  });

  final String guess;
  final int totalMatches;
  final int exactMatches;

  Map<String, Object?> toJson() {
    return {
      'guess': guess,
      'totalMatches': totalMatches,
      'exactMatches': exactMatches,
    };
  }

  static GuessRecord fromJson(Map<String, Object?> json) {
    return GuessRecord(
      guess: json['guess']! as String,
      totalMatches: json['totalMatches']! as int,
      exactMatches: json['exactMatches']! as int,
    );
  }
}

class NotebookEntry {
  const NotebookEntry({
    required this.digitMarks,
    required this.note,
    this.guesses = const [],
  });

  factory NotebookEntry.empty() {
    return const NotebookEntry(digitMarks: {}, note: '');
  }

  final Map<int, DigitMark> digitMarks;
  final String note;
  final List<GuessRecord> guesses;

  NotebookEntry copyWith({
    Map<int, DigitMark>? digitMarks,
    String? note,
    List<GuessRecord>? guesses,
  }) {
    return NotebookEntry(
      digitMarks: digitMarks ?? this.digitMarks,
      note: note ?? this.note,
      guesses: guesses ?? this.guesses,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'digitMarks': digitMarks.map(
        (digit, mark) => MapEntry(digit.toString(), mark.name),
      ),
      'note': note,
      'guesses': guesses.map((guess) => guess.toJson()).toList(),
    };
  }

  static NotebookEntry fromJson(Map<String, Object?> json) {
    final rawMarks = Map<String, Object?>.from(
      (json['digitMarks'] as Map<dynamic, dynamic>?) ?? const {},
    );
    final rawGuesses = (json['guesses'] as List<dynamic>?) ?? const [];
    return NotebookEntry(
      digitMarks: rawMarks.map((digit, markName) {
        return MapEntry(
          int.parse(digit),
          DigitMark.values.byName(markName! as String),
        );
      }),
      note: (json['note'] as String?) ?? '',
      guesses: rawGuesses
          .map(
            (item) => GuessRecord.fromJson(
              Map<String, Object?>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
    );
  }
}
