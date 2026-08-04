#!/usr/bin/env python3
"""Monotonic difficulty curve for 30 Safe-code levels."""

from __future__ import annotations

from dataclasses import dataclass

PATTERN_WEIGHT: dict[str, int] = {
    "full_match": 1,
    "all_present_one_exact": 2,
    "near_complete": 3,
    "two_exact": 4,
    "one_exact_two_wrong": 5,
    "mixed_cross": 6,
    "double_wrong": 7,
    "all_wrong_positions": 8,
    "triple_elimination": 9,
}

# Patterns ordered from easiest to hardest; cycle for levels 1..30.
PATTERN_LADDER = [
    "full_match",
    "all_present_one_exact",
    "near_complete",
    "two_exact",
    "one_exact_two_wrong",
    "mixed_cross",
    "double_wrong",
    "all_wrong_positions",
    "triple_elimination",
]


def target_pattern(level_id: int) -> str:
    return PATTERN_LADDER[min(level_id - 1, len(PATTERN_LADDER) - 1)]


def target_restriction_count(level_id: int) -> int:
    if level_id <= 3:
        return 1
    if level_id <= 7:
        return 2
    if level_id <= 12:
        return 2
    if level_id <= 18:
        return 3
    if level_id <= 24:
        return 3
    return 4


def target_max_attempts(level_id: int) -> int:
    if level_id <= 10:
        base = 5
    elif level_id <= 20:
        base = 6
    else:
        base = 7
    # Every fourth level in a chapter is a bit tighter.
    chapter_index = (level_id - 1) % 10
    penalty = chapter_index // 4
    return max(4, base - penalty)


@dataclass
class DifficultyProfile:
    level_id: int
    code_length: int
    pattern: str
    journal_count: int
    restriction_count: int
    max_attempts: int

    @property
    def score(self) -> int:
        pattern_weight = PATTERN_WEIGHT.get(self.pattern, 5)
        return (
            self.level_id * 10
            + pattern_weight * 3
            + self.restriction_count * 2
            + (self.code_length - 3)
            + (8 - self.max_attempts)
        )


def profile_for(
    level_id: int,
    code: str,
    pattern: str,
    journal_count: int,
    restriction_count: int,
    max_attempts: int,
) -> DifficultyProfile:
    return DifficultyProfile(
        level_id=level_id,
        code_length=len(code),
        pattern=pattern,
        journal_count=journal_count,
        restriction_count=restriction_count,
        max_attempts=max_attempts,
    )
