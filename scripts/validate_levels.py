#!/usr/bin/env python3
"""Validate Safe-code level definitions (mastermind + logic restrictions)."""

from __future__ import annotations

import re
from dataclasses import dataclass


def score_mastermind(code: str, guess: str) -> tuple[int, int]:
    exact = sum(1 for i, g in enumerate(guess) if i < len(code) and code[i] == g)
    code_counts: dict[str, int] = {}
    guess_counts: dict[str, int] = {}
    for d in code:
        code_counts[d] = code_counts.get(d, 0) + 1
    for d in guess:
        guess_counts[d] = guess_counts.get(d, 0) + 1
    total = sum(min(guess_counts.get(d, 0), c) for d, c in code_counts.items())
    return total, exact


def adjacent_pairs(digits: list[int]):
    return [(digits[i], digits[i + 1]) for i in range(len(digits) - 1)]


def validate_logic_restriction(code: str, description: str) -> str | None:
    digits = [int(d) for d in code]
    total_sum = sum(digits)
    even_count = sum(1 for d in digits if d % 2 == 0)
    non_zero_even = sum(1 for d in digits if d != 0 and d % 2 == 0)
    odd_count = sum(1 for d in digits if d % 2 == 1)
    zero_count = sum(1 for d in digits if d == 0)
    unique = len(set(digits)) == len(digits)

    def fail(ok: bool) -> bool:
        return not ok

    if "Цифры не повторяются" in description or "цифры не повторяются" in description:
        if fail(unique):
            return f'"{description}" failed for {code}: digits repeat.'

    if "соседние цифры не отличаются на 1" in description:
        ok = all(abs(a - b) != 1 for a, b in adjacent_pairs(digits))
        if fail(ok):
            return f'"{description}" failed for {code}: adjacent digits differ by 1.'

    sum_match = re.search(r"сумм[аы] цифр равна (\d+)", description) or re.search(
        r"сумма равна (\d+)", description
    )
    if sum_match:
        expected = int(sum_match.group(1))
        if fail(total_sum == expected):
            return f'"{description}" failed for {code}: sum is {total_sum}.'

    checks = [
        ("Последняя цифра больше первой", digits[-1] > digits[0]),
        ("Последняя цифра меньше первой", digits[-1] < digits[0]),
        ("Последняя цифра больше второй", digits[-1] > digits[1]),
        ("последняя больше первой", digits[-1] > digits[0]),
        ("последняя цифра четная", digits[-1] % 2 == 0),
        ("Последняя цифра нечетная", digits[-1] % 2 == 1),
        ("Первая цифра четная", digits[0] % 2 == 0),
        ("Первая цифра нечетная", digits[0] % 2 == 1),
        ("середина равна нулю", digits[len(digits) // 2] == 0),
        ("средняя цифра ровно вдвое меньше первой", digits[1] * 2 == digits[0]),
        ("Средняя цифра равна сумме крайних минус 2", digits[1] == digits[0] + digits[-1] - 2),
        ("Код содержит ровно две нечетные цифры", odd_count == 2),
        ("Ровно две цифры нечетные", odd_count == 2),
        ("Код содержит ровно три четные цифры", even_count == 3),
        ("Код содержит три ненулевые четные цифры", non_zero_even == 3),
        ("В коде три ненулевые четные цифры", non_zero_even == 3),
        ("в коде один ноль", zero_count == 1),
        ("один ноль", zero_count == 1),
        ("Все цифры кода нечетные", odd_count == len(digits)),
        (
            "Цифры идут по возрастанию",
            all(a < b for a, b in adjacent_pairs(digits)),
        ),
        (
            "Цифры идут по убыванию до последней пары",
            all(a > b for a, b in adjacent_pairs(digits)),
        ),
    ]
    for phrase, ok in checks:
        if phrase in description and fail(ok):
            return f'"{description}" failed for {code}.'

    if "Цифры идут не по порядку" in description:
        ascending = all(a < b for a, b in adjacent_pairs(digits))
        descending = all(a > b for a, b in adjacent_pairs(digits))
        if fail(not ascending and not descending):
            return f'"{description}" failed for {code}.'

    if "Первая цифра больше последней" in description:
        if fail(digits[0] > digits[-1]):
            return f'"{description}" failed for {code}.'

    if "Первая цифра меньше средней" in description:
        if fail(digits[0] < digits[1]):
            return f'"{description}" failed for {code}.'

    if "Средняя цифра — самая большая" in description:
        if fail(digits[1] == max(digits)):
            return f'"{description}" failed for {code}.'

    if "Первая и последняя цифры четные" in description:
        if fail(digits[0] % 2 == 0 and digits[-1] % 2 == 0):
            return f'"{description}" failed for {code}.'

    if "Код не содержит нулей" in description:
        if fail(zero_count == 0):
            return f'"{description}" failed for {code}.'

    if "Ровно одна четная цифра" in description:
        if fail(even_count == 1):
            return f'"{description}" failed for {code}: even count is {even_count}.'

    return None


@dataclass
class MastermindClue:
    guess: str
    total: int
    exact: int


def parse_mastermind(description: str) -> MastermindClue:
    guess = re.match(r"^\d+", description).group(0)  # type: ignore[union-attr]

    rules = [
        ("ни одной верной цифры", 0, 0),
        ("все пять цифр верны", 5, 5),
        ("все четыре цифры верны", 4, 4),
        ("все три цифры верны", 3, 3),
        ("все три цифры входят", 3, 1),  # with "одна стоит"
        ("все четыре цифры входят", 4, 1),  # with "одна стоит"
        ("четыре цифры верны и стоят", 4, 4),
        ("три цифры верны и стоят", 3, 3),
        ("две цифры верны и стоят", 2, 2),
        ("одна цифра верна и стоит", 1, 1),
        ("две цифры верны, но стоят не", 2, 0),
        ("одна цифра верна, но стоит не", 1, 0),
        ("две цифры верны, одна стоит", 2, 1),
        ("три цифры верны, но стоят не", 3, 0),
    ]
    for phrase, total, exact in rules:
        if phrase in description:
            if phrase == "все три цифры входят" and "одна стоит" not in description:
                continue
            return MastermindClue(guess, total, exact)
    raise ValueError(f"Unsupported clue: {description}")


@dataclass
class LevelSpec:
    id: int
    code: str
    journals: list[str]
    restrictions: list[str]


LEVELS: list[LevelSpec] = [
    # Easy 1-10: varied 3-digit patterns
    LevelSpec(1, "482", [
        "482: все три цифры верны и стоят на своих местах.",
        "129: одна цифра верна, но стоит не на своем месте.",
    ], ["Цифры не повторяются, сумма цифр равна 14."]),
    LevelSpec(2, "591", [
        "024: ни одной верной цифры.",
        "863: ни одной верной цифры.",
        "317: одна цифра верна, но стоит не на своем месте.",
    ], ["Цифры не повторяются, сумма цифр равна 15."]),
    LevelSpec(3, "394", [
        "943: две цифры верны, но стоят не на своих местах.",
        "349: одна цифра верна, но стоит не на своем месте.",
    ], ["Первая цифра меньше средней, цифры не повторяются."]),
    LevelSpec(4, "630", [
        "603: все три цифры входят в код, одна стоит на своем месте.",
        "918: ни одной верной цифры.",
    ], ["Первая цифра четная, средняя цифра ровно вдвое меньше первой."]),
    LevelSpec(5, "157", [
        "123: одна цифра верна и стоит на своем месте.",
        "570: две цифры верны, но стоят не на своих местах.",
    ], ["Последняя цифра больше первой, цифры не повторяются."]),
    LevelSpec(6, "826", [
        "682: три цифры верны, но стоят не на своих местах.",
        "286: две цифры верны, одна стоит на своем месте.",
    ], ["Сумма цифр равна 16, код не содержит нулей."]),
    LevelSpec(7, "204", [
        "240: две цифры верны, но стоят не на своих местах.",
        "402: две цифры верны, но стоят не на своих местах.",
        "915: ни одной верной цифры.",
    ], ["Сумма цифр равна 6, первая и последняя цифры четные."]),
    LevelSpec(8, "735", [
        "573: две цифры верны, одна стоит на своем месте.",
        "357: две цифры верны, но стоят не на своих местах.",
    ], ["Все цифры кода нечетные, цифры не повторяются."]),
    LevelSpec(9, "518", [
        "581: две цифры верны и стоят на своих местах.",
        "146: ни одной верной цифры.",
    ], ["Средняя цифра — самая большая, сумма цифр равна 14."]),
    LevelSpec(10, "960", [
        "906: все три цифры входят в код, одна стоит на своем месте.",
        "135: ни одной верной цифры.",
        "248: ни одной верной цифры.",
    ], ["Первая цифра больше последней, в коде один ноль."]),
    # Medium 11-20: varied 4-digit patterns
    LevelSpec(11, "7392", [
        "7932: три цифры верны и стоят на своих местах.",
        "1958: одна цифра верна, но стоит не на своем месте.",
    ], ["Сумма цифр равна 21, цифры не повторяются."]),
    LevelSpec(12, "4816", [
        "8641: три цифры верны, но стоят не на своих местах.",
        "1486: две цифры верны, одна стоит на своем месте.",
    ], ["Код содержит ровно три четные цифры."]),
    LevelSpec(13, "2057", [
        "2507: две цифры верны и стоят на своих местах.",
        "7810: две цифры верны, но стоят не на своих местах.",
    ], ["Последняя цифра больше первой, соседние цифры не отличаются на 1."]),
    LevelSpec(14, "3140", [
        "4103: все четыре цифры входят в код, одна стоит на своем месте.",
        "9026: ни одной верной цифры.",
    ], ["Последняя цифра меньше первой, в коде один ноль."]),
    LevelSpec(15, "9631", [
        "6931: три цифры верны, но стоят не на своих местах.",
        "1369: две цифры верны, одна стоит на своем месте.",
    ], ["Первая цифра нечетная, сумма цифр равна 19."]),
    LevelSpec(16, "1478", [
        "1470: три цифры верны и стоят на своих местах.",
        "5806: одна цифра верна, но стоит не на своем месте.",
    ], ["Цифры идут по возрастанию."]),
    LevelSpec(17, "5829", [
        "5298: две цифры верны и стоят на своих местах.",
        "9017: одна цифра верна, но стоит не на своем месте.",
        "3046: ни одной верной цифры.",
    ], ["Последняя цифра больше первой."]),
    LevelSpec(18, "6204", [
        "6024: три цифры верны, но стоят не на своих местах.",
        "4260: две цифры верны, одна стоит на своем месте.",
    ], ["Код содержит три ненулевые четные цифры и один ноль."]),
    LevelSpec(19, "8762", [
        "8672: три цифры верны и стоят на своих местах.",
        "2419: одна цифра верна, но стоит не на своем месте.",
    ], ["Цифры идут по убыванию до последней пары."]),
    LevelSpec(20, "3591", [
        "9531: две цифры верны, но стоят не на своих местах.",
        "1359: две цифры верны, но стоят не на своих местах.",
        "8024: ни одной верной цифры.",
    ], ["Сумма цифр равна 18, цифры не повторяются."]),
    # Hard 21-30
    LevelSpec(21, "72836", [
        "78326: четыре цифры верны и стоят на своих местах.",
        "60419: одна цифра верна, но стоит не на своем месте.",
    ], ["Сумма цифр равна 26, соседние цифры не отличаются на 1."]),
    LevelSpec(22, "93047", [
        "90437: три цифры верны, но стоят не на своих местах.",
        "73049: две цифры верны, одна стоит на своем месте.",
    ], ["Последняя цифра больше второй, в коде один ноль."]),
    LevelSpec(23, "1649", [
        "6194: две цифры верны и стоят на своих местах.",
        "9087: одна цифра верна, но стоит не на своем месте.",
        "2350: ни одной верной цифры.",
    ], ["Ровно две цифры нечетные, сумма цифр равна 20."]),
    LevelSpec(24, "85204", [
        "85024: четыре цифры верны и стоят на своих местах.",
        "4317: одна цифра верна, но стоит не на своем месте.",
    ], ["В коде три ненулевые четные цифры и один ноль."]),
    LevelSpec(25, "40738", [
        "47038: три цифры верны, но стоят не на своих местах.",
        "80347: две цифры верны, одна стоит на своем месте.",
    ], ["Первая цифра четная, последняя больше первой."]),
    LevelSpec(26, "2916", [
        "9216: две цифры верны и стоят на своих местах.",
        "9870: одна цифра верна, но стоит не на своем месте.",
        "4053: ни одной верной цифры.",
    ], ["Сумма цифр равна 18, соседние цифры не отличаются на 1."]),
    LevelSpec(27, "68025", [
        "68205: четыре цифры верны и стоят на своих местах.",
        "5174: одна цифра верна, но стоит не на своем месте.",
    ], ["Последняя цифра нечетная, в коде один ноль."]),
    LevelSpec(28, "73519", [
        "75319: три цифры верны, но стоят не на своих местах.",
        "19537: две цифры верны, одна стоит на своем месте.",
    ], ["Все цифры кода нечетные."]),
    LevelSpec(29, "9240", [
        "4920: все четыре цифры входят в код, одна стоит на своем месте.",
        "7051: одна цифра верна, но стоит не на своем месте.",
    ], ["Последняя цифра меньше первой, сумма цифр равна 15."]),
    LevelSpec(30, "58147", [
        "58417: четыре цифры верны и стоят на своих местах.",
        "7602: одна цифра верна, но стоит не на своем месте.",
    ], ["Последняя цифра больше первой, цифры не повторяются."]),
]


def valid_candidates(level: LevelSpec) -> list[str]:
    length = len(level.code)
    journals = [parse_mastermind(j) for j in level.journals]
    candidates: list[str] = []

    def build(prefix: str) -> None:
        if len(prefix) == length:
            for j in journals:
                total, exact = score_mastermind(prefix, j.guess)
                if total != j.total or exact != j.exact:
                    return
            for r in level.restrictions:
                if validate_logic_restriction(prefix, r):
                    return
            candidates.append(prefix)
            return
        for d in range(10):
            build(prefix + str(d))

    build("")
    return candidates


def main() -> None:
    failures: list[str] = []
    for level in LEVELS:
        for journal in level.journals:
            clue = parse_mastermind(journal)
            total, exact = score_mastermind(level.code, clue.guess)
            if total != clue.total or exact != clue.exact:
                failures.append(
                    f"Level {level.id} journal {clue.guess}: "
                    f"expected {clue.total}/{clue.exact}, got {total}/{exact}"
                )
        for restriction in level.restrictions:
            err = validate_logic_restriction(level.code, restriction)
            if err:
                failures.append(f"Level {level.id}: {err}")
        candidates = valid_candidates(level)
        if level.code not in candidates:
            failures.append(f"Level {level.id}: answer {level.code} not in candidates")
        if len(candidates) != 1:
            failures.append(
                f"Level {level.id}: expected 1 candidate, got {len(candidates)}: {candidates[:8]}"
            )

    if failures:
        print("FAILURES:")
        for f in failures:
            print(f"  - {f}")
        raise SystemExit(1)
    print(f"All {len(LEVELS)} levels validated with unique solutions.")


if __name__ == "__main__":
    main()
