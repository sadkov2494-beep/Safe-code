#!/usr/bin/env python3
"""Generate and validate diverse Safe-code levels."""

from __future__ import annotations

import random
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
    ]
    for phrase, ok in rules:
        if phrase in description and fail(ok):
            return f'"{description}" failed for {code}.'

    if "Цифры идут не по порядку" in description:
        ascending = all(a < b for a, b in adjacent_pairs(digits))
        descending = all(a > b for a, b in adjacent_pairs(digits))
        if fail(not ascending and not descending):
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
        if length == 3:
            return f"{guess}: все три цифры верны и стоят на своих местах."
        if length == 4:
            return f"{guess}: все четыре цифры верны и стоят на своих местах."
        return f"{guess}: все пять цифр верны и стоят на своих местах."
    if total == length and exact == 1 and length in (3, 4, 5):
        word = {3: "три", 4: "четыре", 5: "пять"}[length]
        return f"{guess}: все {word} цифры входят в код, одна стоит на своем месте."
    if total == length and exact == 0:
        word = {3: "три", 4: "четыре", 5: "пять"}[length]
        return f"{guess}: {word} цифры верны, но стоят не на своих местах."
    if exact == length - 1 and total == length - 1:
        word = {2: "две", 3: "три", 4: "четыре"}[length - 1]
        return f"{guess}: {word} цифры верны и стоят на своих местах."
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


def shuffle_digits(code: str, rng: random.Random, *, min_exact: int = 0, max_exact: int = 0) -> str | None:
    digits = list(code)
    for _ in range(200):
        guess_digits = digits[:]
        rng.shuffle(guess_digits)
        if guess_digits == list(code):
            continue
        guess = "".join(guess_digits)
        total, exact = score_mastermind(code, guess)
        if total == len(code) and min_exact <= exact <= max_exact:
            return guess
    return None


def random_guess(length: int, rng: random.Random) -> str:
    return "".join(str(rng.randint(0, 9)) for _ in range(length))


def find_guess(
    code: str,
    rng: random.Random,
    *,
    total: int | None = None,
    exact: int | None = None,
    exclude: set[str] | None = None,
) -> str | None:
    exclude = exclude or set()
    length = len(code)
    for _ in range(5000):
        guess = random_guess(length, rng)
        if guess in exclude or guess == code:
            continue
        t, e = score_mastermind(code, guess)
        if total is not None and t != total:
            continue
        if exact is not None and e != exact:
            continue
        return guess
    return None


RESTRICTION_POOL = [
    lambda c: f"Сумма цифр равна {sum(int(d) for d in c)}.",
    lambda c: "Цифры не повторяются." if len(set(c)) == len(c) else None,
    lambda c: "Последняя цифра больше первой." if int(c[-1]) > int(c[0]) else None,
    lambda c: "Последняя цифра меньше первой." if int(c[-1]) < int(c[0]) else None,
    lambda c: "Первая цифра четная." if int(c[0]) % 2 == 0 else None,
    lambda c: "Первая цифра нечетная." if int(c[0]) % 2 == 1 else None,
    lambda c: "Все цифры кода нечетные." if all(int(d) % 2 == 1 for d in c) else None,
    lambda c: "Код не содержит нулей." if "0" not in c else None,
    lambda c: "в коде один ноль." if c.count("0") == 1 else None,
    lambda c: (
        "Код содержит ровно две нечетные цифры."
        if sum(1 for d in c if int(d) % 2 == 1) == 2
        else None
    ),
    lambda c: (
        "Код содержит ровно три четные цифры."
        if sum(1 for d in c if int(d) % 2 == 0) == 3
        else None
    ),
    lambda c: (
        "Цифры идут по возрастанию."
        if all(int(c[i]) < int(c[i + 1]) for i in range(len(c) - 1))
        else None
    ),
    lambda c: (
        "соседние цифры не отличаются на 1."
        if all(abs(int(c[i]) - int(c[i + 1])) != 1 for i in range(len(c) - 1))
        else None
    ),
]


@dataclass
class LevelSpec:
    id: int
    code: str
    journals: list[str]
    restrictions: list[str]
    pattern: str


PATTERNS = [
    "full_match_plus_elimination",
    "triple_elimination",
    "all_wrong_positions",
    "all_present_one_exact",
    "one_exact_two_wrong",
    "two_exact_restriction",
    "double_wrong_position",
    "mixed_cross",
    "near_complete",
    "restriction_chain",
]


def build_level(level_id: int, code: str, pattern: str, rng: random.Random) -> LevelSpec | None:
    length = len(code)
    journals: list[str] = []
    restrictions: list[str] = []

    if pattern == "full_match_plus_elimination":
        journals.append(format_journal(code, length, length, length))
        g = find_guess(code, rng, total=1, exact=0)
        if not g:
            return None
        journals.append(format_journal(g, 1, 0, length))
    elif pattern == "triple_elimination":
        for _ in range(2):
            g = find_guess(code, rng, total=0, exact=0, exclude=set(journals))
            if not g:
                return None
            journals.append(format_journal(g, 0, 0, length))
        g = find_guess(code, rng, total=1, exact=0, exclude=set(journals))
        if not g:
            return None
        journals.append(format_journal(g, 1, 0, length))
    elif pattern == "all_wrong_positions":
        g = shuffle_digits(code, rng, max_exact=0)
        if not g:
            return None
        journals.append(format_journal(g, length, 0, length))
        g2 = find_guess(code, rng, total=2, exact=1, exclude={g})
        if not g2:
            return None
        journals.append(format_journal(g2, 2, 1, length))
    elif pattern == "all_present_one_exact":
        if length == 5:
            g = find_guess(code, rng, total=5, exact=1)
        else:
            g = shuffle_digits(code, rng, min_exact=1, max_exact=1)
        if not g:
            return None
        journals.append(format_journal(g, length, 1, length))
        g2 = find_guess(code, rng, total=0, exact=0, exclude={g})
        if g2:
            journals.append(format_journal(g2, 0, 0, length))
    elif pattern == "one_exact_two_wrong":
        g = find_guess(code, rng, total=1, exact=1)
        if not g:
            return None
        journals.append(format_journal(g, 1, 1, length))
        g2 = find_guess(code, rng, total=2, exact=0, exclude={g})
        if not g2:
            return None
        journals.append(format_journal(g2, 2, 0, length))
    elif pattern == "two_exact_restriction":
        # find guess with exactly 2 exact matches
        g = None
        for _ in range(3000):
            cand = random_guess(length, rng)
            if cand == code:
                continue
            t, e = score_mastermind(code, cand)
            if t == 2 and e == 2:
                g = cand
                break
        if not g:
            return None
        journals.append(format_journal(g, 2, 2, length))
        g2 = find_guess(code, rng, total=0, exact=0, exclude={g})
        if g2:
            journals.append(format_journal(g2, 0, 0, length))
    elif pattern == "double_wrong_position":
        for _ in range(2):
            g = find_guess(code, rng, total=2, exact=0, exclude=set(journals))
            if not g:
                return None
            journals.append(format_journal(g, 2, 0, length))
    elif pattern == "mixed_cross":
        g = find_guess(code, rng, total=2, exact=1)
        if not g:
            return None
        journals.append(format_journal(g, 2, 1, length))
        g2 = find_guess(code, rng, total=2, exact=0, exclude={g})
        if not g2:
            return None
        journals.append(format_journal(g2, 2, 0, length))
    elif pattern == "near_complete":
        g = None
        for _ in range(3000):
            cand = random_guess(length, rng)
            if cand == code:
                continue
            t, e = score_mastermind(code, cand)
            if t == length - 1 and e == length - 1:
                g = cand
                break
        if not g:
            return None
        journals.append(format_journal(g, length - 1, length - 1, length))
        g2 = find_guess(code, rng, total=1, exact=0, exclude={g})
        if not g2:
            return None
        journals.append(format_journal(g2, 1, 0, length))
    elif pattern == "restriction_chain":
        g = find_guess(code, rng, total=1, exact=0)
        if not g:
            return None
        journals.append(format_journal(g, 1, 0, length))
        g2 = find_guess(code, rng, total=0, exact=0, exclude={g})
        if g2:
            journals.append(format_journal(g2, 0, 0, length))

    rng.shuffle(RESTRICTION_POOL)
    for maker in RESTRICTION_POOL:
        text = maker(code)
        if text and text not in restrictions:
            restrictions.append(text)
        if len(restrictions) >= (1 if length == 3 else 1):
            break
    if not restrictions:
        restrictions.append(f"Сумма цифр равна {sum(int(d) for d in code)}.")

    return LevelSpec(level_id, code, journals, restrictions, pattern)


def valid_candidates(level: LevelSpec) -> list[str]:
    length = len(level.code)

    def parse_journal(desc: str) -> tuple[str, int, int]:
        guess = re.match(r"^\d+", desc).group(0)  # type: ignore[union-attr]
        total, exact = score_mastermind(level.code, guess)
        # trust formatted descriptions
        rules = [
            ("ни одной верной цифры", 0, 0),
            ("все пять цифр верны", 5, 5),
            ("все четыре цифры верны", 4, 4),
            ("все три цифры верны", 3, 3),
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
                if phrase.endswith("верны") and "входят" not in phrase and "и стоят" not in phrase:
                    continue
                return guess, t, e
        return guess, total, exact

    journals = [parse_journal(j) for j in level.journals]
    candidates: list[str] = []

    def build(prefix: str) -> None:
        if len(prefix) == length:
            for guess, t, e in journals:
                total, exact = score_mastermind(prefix, guess)
                if total != t or exact != e:
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


def generate_catalog() -> list[LevelSpec]:
    rng = random.Random(42)
    codes_easy = ["482", "591", "394", "630", "157", "826", "204", "735", "518", "960"]
    codes_medium = ["7392", "4816", "2057", "3140", "9631", "1478", "5829", "6204", "8762", "3591"]
    codes_hard = ["72836", "93047", "1649", "85204", "40738", "2916", "68025", "73519", "9240", "58147"]
    all_codes = codes_easy + codes_medium + codes_hard
    levels: list[LevelSpec] = []
    used_patterns: dict[str, int] = {p: 0 for p in PATTERNS}

    for i, code in enumerate(all_codes, start=1):
        pattern_order = PATTERNS[:]
        rng.shuffle(pattern_order)
        built: LevelSpec | None = None
        for pattern in pattern_order:
            for attempt in range(120):
                candidate = build_level(i, code, pattern, random.Random(42 + i * 1000 + attempt))
                if not candidate:
                    continue
                solutions = valid_candidates(candidate)
                if solutions == [code]:
                    built = candidate
                    used_patterns[pattern] += 1
                    break
            if built:
                break
        if not built:
            # fallback: near_complete is most reliable
            for attempt in range(500):
                candidate = build_level(i, code, "near_complete", random.Random(9000 + i * 1000 + attempt))
                if not candidate:
                    continue
                solutions = valid_candidates(candidate)
                if solutions == [code]:
                    built = candidate
                    break
        if not built:
            raise RuntimeError(f"Failed to build level {i} code {code}")
        levels.append(built)
    return levels


def main() -> None:
    levels = generate_catalog()
    print(f"Generated {len(levels)} levels")
    for level in levels:
        print(f"\nLevel {level.id} [{level.pattern}] code={level.code}")
        for j in level.journals:
            print(f"  J: {j}")
        for r in level.restrictions:
            print(f"  R: {r}")
        solutions = valid_candidates(level)
        assert solutions == [level.code], f"Level {level.id}: {solutions}"


if __name__ == "__main__":
    main()
