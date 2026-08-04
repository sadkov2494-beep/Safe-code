#!/usr/bin/env python3
"""Annotate levels.dart with archetype, boss flags, difficulty ratings, and false clues."""

from __future__ import annotations

import re
from pathlib import Path

LEVELS_PATH = Path("/workspace/Safe-code/lib/data/levels.dart")

ARCHETYPE_BY_TYPE = {
    "точное совпадение": "PuzzleArchetype.fullMatch",
    "только перестановки": "PuzzleArchetype.allWrongPositions",
    "одна точная позиция": "PuzzleArchetype.oneExactTwoWrong",
    "две точные позиции": "PuzzleArchetype.twoExact",
    "двойная перестановка": "PuzzleArchetype.doubleWrong",
    "почти готовый код": "PuzzleArchetype.nearComplete",
    "пересечение журналов": "PuzzleArchetype.mixedCross",
    "все цифры есть": "PuzzleArchetype.allPresentOneExact",
    "цепочка исключений": "PuzzleArchetype.tripleElimination",
}

FALSE_CLUES = {
    25: ("Журнал 15842", "15842: две цифры верны, но стоят не на своих местах."),
    26: ("Журнал 6192", "6192: две цифры верны, но стоят не на своих местах."),
    27: ("Журнал 28056", "28056: три цифры верны, но стоят не на своих местах."),
    28: ("Журнал 19375", "19375: две цифры верны, но стоят не на своих местах."),
    29: ("Журнал 4029", "4029: две цифры верны, но стоят не на своих местах."),
}


def archetype_for(explanation: str) -> str:
    for key, value in ARCHETYPE_BY_TYPE.items():
        if key in explanation:
            return value
    return "PuzzleArchetype.fullMatch"


def difficulty_rating(level_id: int) -> int:
    if level_id <= 10:
        return 10 + level_id * 2
    if level_id <= 20:
        return 30 + (level_id - 10) * 3
    return 60 + (level_id - 20) * 4


def main() -> None:
    text = LEVELS_PATH.read_text(encoding="utf-8")

    text = text.replace(
        "import '../models/clue.dart';\nimport '../models/level.dart';",
        "import '../models/clue.dart';\nimport '../models/level.dart';\nimport '../models/puzzle_archetype.dart';",
    )

    text = re.sub(
        r"Clue _m\(String title, String description, \{bool important = false\}\) \{",
        "Clue _m(String title, String description, {bool important = false, bool isReliable = true}) {",
        text,
    )
    text = text.replace(
        "    isImportant: important,\n  );\n}\n\nClue _l",
        "    isImportant: important,\n    isReliable: isReliable,\n  );\n}\n\nClue _l",
    )

    level_blocks = list(re.finditer(r"  Level\(\n    id: (\d+),", text))
    offsets: list[tuple[int, int, int]] = []
    for match in level_blocks:
        level_id = int(match.group(1))
        offsets.append((level_id, match.start(), match.end()))

    insertions: list[tuple[int, str]] = []
    for level_id, _, end in offsets:
        explanation_match = re.search(
            rf"id: {level_id},[\s\S]*?solutionExplanation:\n        '([^']+)'",
            text,
        )
        explanation = explanation_match.group(1) if explanation_match else ""
        archetype = archetype_for(explanation)
        rating = difficulty_rating(level_id)
        is_boss = level_id in (10, 20, 30)
        boss_line = "    isBoss: true,\n" if is_boss else ""
        insertions.append(
            (
                end,
                f"    archetype: {archetype},\n"
                f"{boss_line}"
                f"    difficultyRating: {rating},\n",
            )
        )

    for pos, snippet in sorted(insertions, key=lambda item: item[0], reverse=True):
        text = text[:pos] + snippet + text[pos:]

    for level_id, (title, description) in FALSE_CLUES.items():
        pattern = (
            rf"(  Level\(\n    id: {level_id},[\s\S]*?logicalClues: \[\n)"
            rf"(      _m\(\n        'Журнал )"
        )
        replacement = (
            rf"\1      _m(\n        '{title}',\n"
            rf"        '{description}',\n"
            rf"        isReliable: false\n"
            rf"      ),\n"
            rf"\2"
        )
        text, count = re.subn(pattern, replacement, text, count=1)
        if count != 1:
            raise RuntimeError(f"Failed to insert false clue for level {level_id}")

    LEVELS_PATH.write_text(text, encoding="utf-8")
    print(f"Annotated {len(offsets)} levels in {LEVELS_PATH}")


if __name__ == "__main__":
    main()
