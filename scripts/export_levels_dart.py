#!/usr/bin/env python3
"""Export curated diverse levels into levels.dart."""

from __future__ import annotations

import re
from pathlib import Path

from fast_generate_levels import (
    LevelSpec,
    build_patterns,
    format_journal,
    pick_restrictions,
    valid_candidates,
    find_guess,
    find_zero_guess,
    near_complete_guess,
    permute_guess,
    score_mastermind,
)

FORCED_PATTERNS: dict[int, str] = {
    1: "full_match",
    2: "triple_elimination",
    3: "all_wrong_positions",
    4: "all_present_one_exact",
    5: "one_exact_two_wrong",
    6: "all_wrong_positions",
    7: "double_wrong",
    8: "mixed_cross",
    9: "two_exact",
    10: "all_wrong_positions",
    11: "near_complete",
    12: "all_wrong_positions",
    13: "one_exact_two_wrong",
    14: "all_present_one_exact",
    15: "mixed_cross",
    16: "near_complete",
    17: "triple_elimination",
    18: "all_wrong_positions",
    19: "all_wrong_positions",
    20: "double_wrong",
    21: "near_complete",
    22: "mixed_cross",
    23: "triple_elimination",
    24: "near_complete",
    25: "one_exact_two_wrong",
    26: "two_exact",
    27: "near_complete",
    28: "all_present_one_exact",
    29: "all_present_one_exact",
    30: "near_complete",
}

PATTERN_TITLES = {
    "full_match": "точное совпадение в журнале",
    "triple_elimination": "цепочка исключений",
    "all_wrong_positions": "только перестановки",
    "all_present_one_exact": "все цифры на месте почти",
    "one_exact_two_wrong": "одна точная позиция",
    "two_exact": "две точные позиции",
    "double_wrong": "двойная перестановка",
    "mixed_cross": "пересечение журналов",
    "near_complete": "почти готовый код",
}

CODES = [
    "482", "157", "630", "294", "718", "365", "941", "520", "806", "273",
    "7392", "4816", "2057", "9631", "1478", "6204", "5829", "3140", "8762", "4591",
    "72836", "93047", "1649", "85204", "40738", "2916", "68025", "73519", "9240", "58147",
]

ORIGINAL = Path("/workspace/Safe-code/lib/data/levels.dart").read_text(encoding="utf-8")


def extract_block(level_id: int) -> str:
    marker = f"id: {level_id},"
    start = ORIGINAL.index(marker)
    depth = 0
    i = ORIGINAL.rfind("Level(", 0, start)
    for j in range(i, len(ORIGINAL)):
        if ORIGINAL[j : j + 5] == "Level":
            depth += 1
        if ORIGINAL[j] == ")" and j > i + 10:
            depth -= 1
            if depth == 0:
                return ORIGINAL[i : j + 2]
    raise RuntimeError(f"block {level_id}")


def build_forced_level(level_id: int, code: str, pattern: str) -> LevelSpec:
    options = dict(build_patterns(code))
    pattern_order = [pattern] + [p for p in FORCED_PATTERNS.values() if p != pattern]
    for candidate_pattern in pattern_order:
        if candidate_pattern not in options:
            continue
        journals = options[candidate_pattern]
        for start in range(30):
            for count in range(1, 5):
                restrictions = pick_restrictions(code, count, start)
                try:
                    solutions = valid_candidates(code, journals, restrictions)
                except ValueError:
                    continue
                if solutions == [code]:
                    return LevelSpec(level_id, code, journals, restrictions, candidate_pattern)
    raise RuntimeError(f"Level {level_id}: no unique solution")


HINTS = {
    "full_match": "Одна запись уже полностью совпадает — проверь её ограничениями.",
    "triple_elimination": "Сначала вычеркни цифры из пустых журналов, потом используй единственную подсказку.",
    "all_wrong_positions": "Цифры верны, но их нужно переставить — ищи фиксированную позицию во второй записи.",
    "all_present_one_exact": "Все цифры уже известны — осталось найти единственную точную позицию.",
    "one_exact_two_wrong": "Одна позиция точна, две цифры нужно переставить.",
    "two_exact": "Две позиции уже стоят на месте — добери остальное из ограничений.",
    "double_wrong": "Обе записи дают только перестановки — ищи пересечение ограничений.",
    "mixed_cross": "Сопоставь точную позицию из первой записи с перестановкой из второй.",
    "near_complete": "Почти весь код известен — замени одну цифру с учётом ограничений.",
}


def explain(level: LevelSpec) -> str:
    parts = [f"Тип головоломки: {PATTERN_TITLES.get(level.pattern, level.pattern)}."]
    for journal in level.journals:
        parts.append(journal)
    parts.extend(level.restrictions)
    parts.append(f"Итоговый код — {level.code}.")
    return " ".join(parts)


def render_journal(journal: str, important: bool) -> str:
    guess = re.match(r"^\d+", journal).group(0)  # type: ignore[union-attr]
    text = journal.split(": ", 1)[1]
    imp = ", important: true" if important else ""
    return f"      _m(\n        'Журнал {guess}',\n        '{journal}',\n        {imp.strip() or ''}\n      ),".replace(",\n        \n      ", "\n      ")


def render_logic(restriction: str) -> str:
    return f"      _l('Ограничение', '{restriction}'),"


def patch_level_block(block: str, level: LevelSpec) -> str:
    # logical clues
    journal_lines = []
    for index, journal in enumerate(level.journals):
        guess = re.match(r"^\d+", journal).group(0)  # type: ignore[union-attr]
        text = journal.split(": ", 1)[1]
        imp = ",\n        important: true" if index == 0 else ""
        journal_lines.append(
            f"      _m(\n        'Журнал {guess}',\n        '{journal}',{imp}\n      ),"
        )
    logic_lines = [render_logic(r) for r in level.restrictions]
    new_logical = "\n".join(journal_lines + logic_lines)

    block = re.sub(
        r"logicalClues: \[.*?\],\n    visualClues:",
        f"logicalClues: [\n{new_logical}\n    ],\n    visualClues:",
        block,
        count=1,
        flags=re.S,
    )

    block = re.sub(
        r"correctCode: '[^']*'",
        f"correctCode: '{level.code}'",
        block,
        count=1,
    )
    block = re.sub(
        r"codeLength: \d+",
        f"codeLength: {len(level.code)}",
        block,
        count=1,
    )
    block = re.sub(
        r"softHint: '[^']*'",
        f"softHint: '{HINTS[level.pattern]}'",
        block,
        count=1,
    )
    block = re.sub(
        r"solutionExplanation:\n        '[^']*'",
        f"solutionExplanation:\n        '{explain(level)}'",
        block,
        count=1,
    )
    return block


def main() -> None:
    levels = [build_forced_level(i, code, FORCED_PATTERNS[i]) for i, code in enumerate(CODES, start=1)]
    header = ORIGINAL.split("final List<Level> allLevels = [", 1)[0] + "final List<Level> allLevels = [\n"
    body_parts = [patch_level_block(extract_block(lv.id), lv) for lv in levels]
    footer = "\n];\n"
    out = header + ",\n  ".join(body_parts) + footer
    Path("/workspace/Safe-code/lib/data/levels.dart").write_text(out, encoding="utf-8")
    print("Wrote levels.dart")
    for lv in levels:
        print(f"{lv.id:2} {lv.pattern:22} {lv.code}")


if __name__ == "__main__":
    main()
