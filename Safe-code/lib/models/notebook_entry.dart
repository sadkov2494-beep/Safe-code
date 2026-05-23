enum DigitMark { unknown, candidate, rejected, confirmed }

class NotebookEntry {
  const NotebookEntry({required this.digitMarks, required this.note});

  factory NotebookEntry.empty() {
    return const NotebookEntry(digitMarks: {}, note: '');
  }

  final Map<int, DigitMark> digitMarks;
  final String note;

  NotebookEntry copyWith({Map<int, DigitMark>? digitMarks, String? note}) {
    return NotebookEntry(
      digitMarks: digitMarks ?? this.digitMarks,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'digitMarks': digitMarks.map(
        (digit, mark) => MapEntry(digit.toString(), mark.name),
      ),
      'note': note,
    };
  }

  static NotebookEntry fromJson(Map<String, Object?> json) {
    final rawMarks = Map<String, Object?>.from(
      (json['digitMarks'] as Map<dynamic, dynamic>?) ?? const {},
    );
    return NotebookEntry(
      digitMarks: rawMarks.map((digit, markName) {
        return MapEntry(
          int.parse(digit),
          DigitMark.values.byName(markName! as String),
        );
      }),
      note: (json['note'] as String?) ?? '',
    );
  }
}
