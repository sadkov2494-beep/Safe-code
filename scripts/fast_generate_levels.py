#!/usr/bin/env python3
"""Fast deterministic level generator for Safe-code."""

from __future__ import annotations

import re
from dataclasses import dataclass

# Reuse validation helpers from generate_levels by importing or duplicating minimal set

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

    rules: list[tuple[str, bool]] = [
        ("Цифры не повторяются", unique),
        ("цифры не повторяются", unique),
        ("соседние цифры не отличаются на 1", all(abs(a - b) != 1 for a, b in adjacent_pairs(digits))),
        ("Последняя цифра больше первой", digits[-1] > digits[0]),
        ("Последняя цифра меньше первой", digits[-1] < digits[0]),
        ("Последняя цифра больше второй", digits[-1] > digits[1]),
        ("последняя больше первой", digits[-1] > digits[0]),
        ("последняя цифра четная", digits[-1] % 2 == 0),
        ("Последняя цифра нечетная", digits[-1] % 2 == 1),
        ("Первая цифра четная", digits[0] % 2 == 0),
        ("Первая цифра нечетная", digits[0] % 2 == 1),
        ("Первая цифра больше последней", digits[0] > digits[-1]),
        ("Первая цифра меньше средней", digits[0] < digits[1]),
        ("середина равна нулю", digits[len(digits) // 2] == 0),
        ("средняя цифра ровно вдвое меньше первой", digits[1] * 2 == digits[0]),
        ("Средняя цифра равна сумме крайних минус 2", digits[1] == digits[0] + digits[-1] - 2),
        ("Средняя цифра — самая большая", digits[1] == max(digits)),
        ("Первая и последняя цифры четные", digits[0] % 2 == 0 and digits[-1] % 2 == 0),
        ("Код не содержит нулей", zero_count == 0),
        ("Код содержит ровно две нечетные цифры", odd_count == 2),
        ("Ровно две цифры нечетные", odd_count == 2),
        ("Код содержит ровно три четные цифры", even_count == 3),
        ("Код содержит три ненулевые четные цифры", non_zero_even == 3),
        ("В коде три ненулевые четные цифры", non_zero_even == 3),
        ("в коде один ноль", zero_count == 1),
        ("один ноль", zero_count == 1),
        ("Все цифры кода нечетные", odd_count == len(digits)),
        ("Цифры идут по возрастанию", all(a < b for a, b in adjacent_pairs(digits))),
        ("Цифры идут по убыванию до последней пары", all(a > b for a, b in adjacent_pairs(digits))),
        ("Цифры идут не по порядку", not all(a < b for a, b in adjacent_pairs(digits)) and not all(a > b for a, b in adjacent_pairs(digits))),
    ]
    for phrase, ok in rules:
        if phrase in description and fail(ok):
            return f'"{description}" failed for {code}.'

    sum_match = re.search(r"сумм[аы] цифр равна (\d+)", description) or re.search(
        r"сумма равна (\d+)", description
    )
    if sum_match:
        expected = int(sum_match.group(1))
        if fail(total_sum == expected):
            return f'"{description}" failed for {code}: sum is {total_sum}.'
    return None


def format_journal(guess: str, total: int, exact: int, length: int) -> str:
    if total == 0:
        return f"{guess}: ни одной верной цифры."
    if total == length and exact == length:
        words = {3: "три", 4: "четыре", 5: "пять"}
        return f"{guess}: все {words[length]} цифры верны и стоят на своих местах."
    if total == length and exact == 1:
        words = {3: "три", 4: "четыре", 5: "пять"}
        return f"{guess}: все {words[length]} цифры входят в код, одна стоит на своем месте."
    if total == length and exact == 0:
        words = {3: "три", 4: "четыре", 5: "пять"}
        return f"{guess}: {words[length]} цифры верны, но стоят не на своих местах."
    if exact == length - 1 and total == length - 1:
        words = {2: "две", 3: "три", 4: "четыре"}
        return f"{guess}: {words[length - 1]} цифры верны и стоят на своих местах."
    if exact == 2 and total == 2:
        return f"{guess}: две цифры верны и стоят на своих местах."
    if exact == 1 and total == 1:
        return f"{guess}: одна цифра верна и стоит на своем месте."
    if exact == 0 and total == 2:
        return f"{guess}: две цифры верны, но стоят не на своих местах."
    if exact == 0 and total == 1:
        return f"{guess}: одна цифра верна, но стоит не на своем месте."
    if exact == 1 and total == 2:
        return f"{guess}: две цифры верны, одна стоит на своем месте."
    raise ValueError(f"Cannot format guess={guess} total={total} exact={exact} len={length}")


def parse_journal(desc: str) -> tuple[str, int, int]:
    guess = re.match(r"^\d+", desc).group(0)  # type: ignore[union-attr]
    rules = [
        ("ни одной верной цифры", 0, 0),
        ("все пять цифры верны", 5, 5),
        ("все четыре цифры верны", 4, 4),
        ("все три цифры верны", 3, 3),
        ("все пять цифры входят", 5, 1),
        ("все четыре цифры входят", 4, 1),
        ("все три цифры входят", 3, 1),
        ("пять цифр верны, но", 5, 0),
        ("четыре цифры верны, но", 4, 0),
        ("три цифры верны, но", 3, 0),
        ("четыре цифры верны и стоят", 4, 4),
        ("три цифры верны и стоят", 3, 3),
        ("две цифры верны и стоят", 2, 2),
        ("одна цифра верна и стоит", 1, 1),
        ("две цифры верны, но", 2, 0),
        ("одна цифра верна, но", 1, 0),
        ("две цифры верны, одна стоит", 2, 1),
    ]
    for phrase, t, e in rules:
        if phrase in desc:
            if "входят" in phrase and "одна стоит" not in desc:
                continue
            return guess, t, e
    raise ValueError(desc)


def valid_candidates(code: str, journals: list[str], restrictions: list[str]) -> list[str]:
    length = len(code)
    parsed = [parse_journal(j) for j in journals]

    def build(prefix: str) -> None:
        if len(prefix) == length:
            for guess, t, e in parsed:
                total, exact = score_mastermind(prefix, guess)
                if total != t or exact != e:
                    return
            for r in restrictions:
                if validate_logic_restriction(prefix, r):
                    return
            out.append(prefix)
            return
        for d in range(10):
            build(prefix + str(d))

    out: list[str] = []
    build("")
    return out


def find_guess(code: str, total: int, exact: int, exclude: set[str] | None = None) -> str | None:
    exclude = exclude or set()
    length = len(code)
    for n in range(10**length):
        guess = str(n).zfill(length)
        if guess == code or guess in exclude:
            continue
        t, e = score_mastermind(code, guess)
        if t == total and e == exact:
            return guess
    return None


def find_zero_guess(code: str, exclude: set[str] | None = None) -> str:
    exclude = exclude or set()
    length = len(code)
    code_set = set(code)
    for n in range(10**length):
        guess = str(n).zfill(length)
        if guess in exclude:
            continue
        if not set(guess).intersection(code_set):
            return guess
    raise RuntimeError("no zero guess")


def permute_guess(code: str, exact: int) -> str | None:
    from itertools import permutations

    length = len(code)
    for perm in permutations(code):
        g = "".join(perm)
        if g == code:
            continue
        t, e = score_mastermind(code, g)
        if t == length and e == exact:
            return g
    return None


def near_complete_guess(code: str) -> str:
    length = len(code)
    chars = list(code)
    for i in range(length):
        for d in "0123456789":
            if d == chars[i]:
                continue
            trial = chars[:]
            trial[i] = d
            g = "".join(trial)
            t, e = score_mastermind(code, g)
            if t == length - 1 and e == length - 1:
                return g
    raise RuntimeError("no near complete")


RESTRICTIONS = [
    lambda c: f"Сумма цифр равна {sum(int(d) for d in c)}.",
    lambda c: "Цифры не повторяются." if len(set(c)) == len(c) else None,
    lambda c: "Последняя цифра больше первой." if int(c[-1]) > int(c[0]) else None,
    lambda c: "Последняя цифра меньше первой." if int(c[-1]) < int(c[0]) else None,
    lambda c: "Первая цифра четная." if int(c[0]) % 2 == 0 else None,
    lambda c: "Первая цифра нечетная." if int(c[0]) % 2 == 1 else None,
    lambda c: "Все цифры кода нечетные." if all(int(d) % 2 == 1 for d in c) else None,
    lambda c: "Код не содержит нулей." if "0" not in c else None,
    lambda c: "в коде один ноль." if c.count("0") == 1 else None,
    lambda c: "Код содержит ровно две нечетные цифры." if sum(1 for d in c if int(d) % 2) == 2 else None,
    lambda c: "Код содержит ровно три четные цифры." if sum(1 for d in c if int(d) % 2 == 0) == 3 else None,
    lambda c: "Цифры идут по возрастанию." if all(int(c[i]) < int(c[i + 1]) for i in range(len(c) - 1)) else None,
    lambda c: "соседние цифры не отличаются на 1." if all(abs(int(c[i]) - int(c[i + 1])) != 1 for i in range(len(c) - 1)) else None,
    lambda c: "Средняя цифра — самая большая." if int(c[1]) == max(int(d) for d in c) and len(c) == 3 else None,
    lambda c: "Первая цифра больше последней." if int(c[0]) > int(c[-1]) else None,
]


@dataclass
class LevelSpec:
    id: int
    code: str
    journals: list[str]
    restrictions: list[str]
    pattern: str


def pick_restrictions(code: str, count: int = 1, start: int = 0) -> list[str]:
    picked: list[str] = []
    pool = RESTRICTIONS[start:] + RESTRICTIONS[:start]
    for maker in pool:
        text = maker(code)
        if text and text not in picked:
            picked.append(text)
        if len(picked) >= count:
            break
    if not picked:
        picked.append(f"Сумма цифр равна {sum(int(d) for d in code)}.")
    return picked


def build_patterns(code: str) -> list[tuple[str, list[str]]]:
    length = len(code)
    patterns: list[tuple[str, list[str]]] = []

    g_partial = find_guess(code, 1, 0, {code})
    if g_partial:
        patterns.append(("full_match", [format_journal(code, length, length, length), format_journal(g_partial, 1, 0, length)]))

    z1 = find_zero_guess(code)
    z2 = find_zero_guess(code, {z1})
    g = find_guess(code, 1, 0, {z1, z2})
    if g:
        patterns.append(("triple_elimination", [format_journal(z1, 0, 0, length), format_journal(z2, 0, 0, length), format_journal(g, 1, 0, length)]))

    g1 = permute_guess(code, 0)
    g2 = find_guess(code, 2, 1, {g1} if g1 else set())
    if g1 and g2:
        patterns.append(("all_wrong_positions", [format_journal(g1, length, 0, length), format_journal(g2, 2, 1, length)]))

    g1 = permute_guess(code, 1)
    if g1:
        patterns.append(("all_present_one_exact", [format_journal(g1, length, 1, length)]))

    g1 = find_guess(code, 1, 1)
    g2 = find_guess(code, 2, 0, {g1} if g1 else set())
    if g1 and g2:
        patterns.append(("one_exact_two_wrong", [format_journal(g1, 1, 1, length), format_journal(g2, 2, 0, length)]))

    g1 = find_guess(code, 2, 2)
    if g1:
        patterns.append(("two_exact", [format_journal(g1, 2, 2, length)]))

    g1 = find_guess(code, 2, 0)
    g2 = find_guess(code, 2, 0, {g1} if g1 else set())
    if g1 and g2:
        patterns.append(("double_wrong", [format_journal(g1, 2, 0, length), format_journal(g2, 2, 0, length)]))

    g1 = find_guess(code, 2, 1)
    g2 = find_guess(code, 2, 0, {g1} if g1 else set())
    if g1 and g2:
        patterns.append(("mixed_cross", [format_journal(g1, 2, 1, length), format_journal(g2, 2, 0, length)]))

    nc = near_complete_guess(code)
    g2 = find_guess(code, 1, 0, {nc})
    if g2:
        patterns.append(("near_complete", [format_journal(nc, length - 1, length - 1, length), format_journal(g2, 1, 0, length)]))

    return patterns


def generate_catalog() -> list[LevelSpec]:
    codes = [
        "482", "591", "394", "630", "157", "826", "204", "735", "518", "960",
        "7392", "4816", "2057", "3140", "9631", "1478", "5829", "6204", "8762", "3591",
        "72836", "93047", "1649", "85204", "40738", "2916", "68025", "73519", "9240", "58147",
    ]
    pattern_cycle = [
        "triple_elimination",
        "all_wrong_positions",
        "all_present_one_exact",
        "one_exact_two_wrong",
        "two_exact",
        "double_wrong",
        "mixed_cross",
        "near_complete",
        "full_match",
    ]
    levels: list[LevelSpec] = []
    for i, code in enumerate(codes, start=1):
        options = {name: journals for name, journals in build_patterns(code)}
        chosen = None
        pattern_order = pattern_cycle[:]
        if i == 1:
            pattern_order = ["full_match"] + [p for p in pattern_order if p != "full_match"]
        elif i == 4:
            pattern_order = ["all_present_one_exact"] + [p for p in pattern_order if p != "all_present_one_exact"]
        else:
            pattern_order = [p for p in pattern_order if p != "full_match"] + ["full_match"]

        for offset, name in enumerate(pattern_order):
            if name not in options:
                continue
            for restriction_start in range(len(RESTRICTIONS)):
                for extra_restrictions in range(1, 4):
                    restrictions = pick_restrictions(code, extra_restrictions, restriction_start)
                    try:
                        solutions = valid_candidates(code, options[name], restrictions)
                    except ValueError:
                        continue
                    if solutions == [code]:
                        chosen = LevelSpec(i, code, options[name], restrictions, name)
                        break
                if chosen:
                    break
            if chosen:
                break
        if not chosen:
            raise RuntimeError(f"Failed level {i} {code}")
        levels.append(chosen)
    return levels


if __name__ == "__main__":
    levels = generate_catalog()
    print(f"OK {len(levels)} levels")
    for lv in levels:
        print(f"{lv.id:2} {lv.pattern:22} {lv.code} -> {lv.journals}")
