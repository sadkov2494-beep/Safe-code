enum PuzzleArchetype {
  fullMatch,
  allPresentOneExact,
  nearComplete,
  twoExact,
  oneExactTwoWrong,
  mixedCross,
  doubleWrong,
  allWrongPositions,
  tripleElimination,
}

extension PuzzleArchetypeLabels on PuzzleArchetype {
  String get label {
    return switch (this) {
      PuzzleArchetype.fullMatch => 'Точное совпадение',
      PuzzleArchetype.allPresentOneExact => 'Все цифры есть',
      PuzzleArchetype.nearComplete => 'Почти готовый код',
      PuzzleArchetype.twoExact => 'Две точные позиции',
      PuzzleArchetype.oneExactTwoWrong => 'Одна точная позиция',
      PuzzleArchetype.mixedCross => 'Пересечение журналов',
      PuzzleArchetype.doubleWrong => 'Двойная перестановка',
      PuzzleArchetype.allWrongPositions => 'Только перестановки',
      PuzzleArchetype.tripleElimination => 'Цепочка исключений',
    };
  }

  String get hint {
    return switch (this) {
      PuzzleArchetype.fullMatch =>
        'Одна запись уже полностью совпадает — проверь её ограничениями.',
      PuzzleArchetype.allPresentOneExact =>
        'Все цифры уже известны — найди единственную точную позицию.',
      PuzzleArchetype.nearComplete =>
        'Почти весь код известен — замени одну цифру с учётом ограничений.',
      PuzzleArchetype.twoExact =>
        'Две позиции уже стоят на месте — добери остальное из ограничений.',
      PuzzleArchetype.oneExactTwoWrong =>
        'Одна позиция точна, две цифры нужно переставить.',
      PuzzleArchetype.mixedCross =>
        'Сопоставь точную позицию из первой записи с перестановкой из второй.',
      PuzzleArchetype.doubleWrong =>
        'Обе записи дают только перестановки — ищи пересечение ограничений.',
      PuzzleArchetype.allWrongPositions =>
        'Цифры верны, но их нужно переставить — ищи фиксированную позицию.',
      PuzzleArchetype.tripleElimination =>
        'Сначала вычеркни цифры из пустых журналов, потом используй подсказку.',
    };
  }

  int get weight {
    return switch (this) {
      PuzzleArchetype.fullMatch => 1,
      PuzzleArchetype.allPresentOneExact => 2,
      PuzzleArchetype.nearComplete => 3,
      PuzzleArchetype.twoExact => 4,
      PuzzleArchetype.oneExactTwoWrong => 5,
      PuzzleArchetype.mixedCross => 6,
      PuzzleArchetype.doubleWrong => 7,
      PuzzleArchetype.allWrongPositions => 8,
      PuzzleArchetype.tripleElimination => 9,
    };
  }
}
