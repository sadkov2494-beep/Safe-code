#!/usr/bin/env python3
"""Generate complete levels.dart with diverse puzzle logic."""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from export_levels_dart import CODES, FORCED_PATTERNS, HINTS, build_forced_level, explain
from fast_generate_levels import LevelSpec

ORIGINAL = Path("/workspace/Safe-code/lib/data/levels.dart").read_text(encoding="utf-8")

LEVEL_META = [
    ("Архивный ящик", "easy", 5, ["fingerprintScanner", "decryptor"], "Стертые кнопки", "На клавишах 4 и 8 матовая поверхность стерта сильнее.", "Тепловой след", "Слабое тепло осталось на нижней правой клавише 2."),
    ("Пыльная панель", "easy", 5, ["fingerprintScanner", "thermalViewer"], "Отпечаток", "На 7 виден свежий отпечаток у правого края.", "Записка", 'На записке указано: "середина меньше краев".'),
    ("Нулевой след", "easy", 5, ["decryptor", "analyzer"], "Царапина", "Царапина начинается возле 6 и тянется к центру панели.", "Пятно пыли", "Кнопка 0 чище соседних клавиш."),
    ("Латунный замок", "easy", 5, ["thermalViewer", "stethoscope"], "Стертый угол", "У клавиши 9 стерта верхняя грань.", "Записка", 'На листке рядом написано: "края уже почти на месте".'),
    ("Тихий коридор", "easy", 5, ["fingerprintScanner", "analyzer"], "Тепловой след", "На 8 сохранился самый яркий след последнего нажатия.", "Папка улик", "В папке выделены цифры 7, 1 и 8."),
    ("Слабая лампа", "easy", 5, ["thermalViewer", "decryptor"], "Отпечаток", "На 6 найден отпечаток в центре панели.", "Потертая кнопка", "Клавиша 5 нажималась чаще остальных в нижнем ряду."),
    ("Северный сейф", "easy", 5, ["fingerprintScanner", "stethoscope"], "Записка", 'На стикере: "начинается с самой большой улики".', "Царапины", "Царапины рядом с 9 заметно глубже остальных."),
    ("Мокрый бетон", "easy", 5, ["thermalViewer", "decryptor"], "Тепловизор охраны", "В журнале тепла видна нулевая клавиша.", "Пыль", "На 5 и 2 нет свежей пыли после нажатия."),
    ("Синяя подсветка", "easy", 5, ["analyzer", "stethoscope"], "Светодиод", "Подсветка вокруг 0 ярче в центральной ячейке.", "Стертые кнопки", "8 и 6 выглядят недавно очищенными."),
    ("Красная папка", "easy", 5, ["fingerprintScanner", "decryptor"], "Записка", 'В папке подчеркнута фраза: "семь между краями".', "Отпечаток", "На 7 найден частичный отпечаток."),
    ("Стеклянная дверь", "medium", 6, ["thermalViewer", "analyzer", "decryptor"], "Тепловая сетка", "У второй позиции виден след 3.", "Царапина", "Возле 9 царапина направлена к третьему окну кода."),
    ("Комната хранения", "medium", 6, ["fingerprintScanner", "stethoscope", "decryptor"], "Отпечатки", "На 4 и 6 остались отчетливые отпечатки.", "Стикер", 'Записано: "8 не стоит первым".'),
    ("Черная бирка", "medium", 6, ["thermalViewer", "analyzer", "decryptor"], "Тепловой след", "Последней нажимали 7.", "Пыль", "0 очищен только в центральной колонке."),
    ("Лифт без звука", "medium", 6, ["stethoscope", "analyzer", "fingerprintScanner"], "Прослушка", "Самый чистый щелчок слышен на 1.", "Папка", "В старой попытке зачеркнут ноль на конце."),
    ("Файл \"Север\"", "medium", 6, ["decryptor", "thermalViewer", "analyzer"], "Записка", 'На записке: "лестница заканчивается четной цифрой".', "Стертая клавиша", "8 выглядит свежее остальных четных кнопок."),
    ("Пульт охраны", "medium", 6, ["fingerprintScanner", "thermalViewer", "decryptor"], "Отпечаток", "На 4 отпечаток частично закрыт пылью.", "Тепло", "Ноль недавно нажимался в третьей позиции."),
    ("Запертый стеллаж", "medium", 6, ["analyzer", "stethoscope", "decryptor"], "Царапины", "Около 9 видны две параллельные царапины.", "Журнал", "В старой записи 0 на конце помечен как ложный."),
    ("Серый планшет", "medium", 6, ["thermalViewer", "fingerprintScanner", "decryptor"], "Тепло", "0 хранит слабый след на правом краю панели.", "Записка", 'Заметка: "конец холодный и круглый".'),
    ("Пятый контейнер", "medium", 6, ["fingerprintScanner", "stethoscope", "analyzer"], "Пыль", "На 2 нет налета, словно ее нажали последней.", "Стикер", 'Подсказка на стикере: "нижний левый финал".'),
    ("Сейф с меткой", "medium", 6, ["decryptor", "thermalViewer", "analyzer"], "Царапина", "Около 9 виден короткий вертикальный след.", "Журнал", "Ноль в третьей позиции помечен красной точкой как ошибка."),
    ("Двойной протокол", "hard", 7, ["stethoscope", "analyzer", "thermalViewer"], "Прослушка", "Самый мягкий щелчок дает последняя клавиша 6.", "Тепло", "Тепловая дуга идет от 7 к 6 через центр панели."),
    ("Зал с отражением", "hard", 7, ["fingerprintScanner", "decryptor", "analyzer"], "Отпечаток", "На 7 найден отпечаток с правой стороны панели.", "Записка", 'Запись на полях: "отражение заканчивает код".'),
    ("Короткий импульс", "hard", 7, ["stethoscope", "analyzer", "decryptor"], "Прослушка", "У 9 самый глубокий щелчок из правого столбца.", "Пыль", "На 0 в журнале виден слой пыли: его не нажимали."),
    ("Пять контактов", "hard", 7, ["thermalViewer", "fingerprintScanner", "decryptor"], "Стертая клавиша", "4 стерта у нижнего края, но не была первой.", "Тепло", "0 оставил холодный провал в четвертой позиции."),
    ("Узел питания", "hard", 7, ["fingerprintScanner", "analyzer", "stethoscope"], "Записка", 'На обороте: "конец выше начала".', "Отпечаток", "На 8 заметен частичный отпечаток большого пальца."),
    ("Складская метка", "hard", 7, ["decryptor", "thermalViewer", "analyzer"], "Царапина", "Царапина у 9 идет к второму окну.", "Журнал", "Ноль во второй позиции перечеркнут дважды."),
    ("Глухой механизм", "hard", 7, ["stethoscope", "fingerprintScanner", "decryptor"], "Прослушка", "У 5 слышен короткий сухой щелчок.", "Пыль", "На последней ячейке есть след округлой кнопки."),
    ("Темный дисплей", "hard", 7, ["thermalViewer", "analyzer", "stethoscope"], "Тепло", "9 оставляет след рядом с правым краем дисплея.", "Записка", 'На листе: "последняя улика самая высокая".'),
    ("Медная рамка", "hard", 7, ["thermalViewer", "decryptor", "analyzer"], "Тепловой след", "Нулевая клавиша холоднее, но недавно нажималась.", "Папка", 'В папке указано: "финал — пустой круг".'),
    ("Последняя ячейка", "hard", 7, ["fingerprintScanner", "stethoscope", "analyzer"], "Отпечаток", "На 7 виден самый четкий отпечаток из всех следов.", "Сейф", "Под последней ячейкой горит слабая зеленая подсветка."),
]


def dart_string(value: str) -> str:
    return value.replace("\\", "\\\\").replace("'", "\\'")


def render_level(level: LevelSpec, meta: tuple) -> str:
    title, difficulty, max_attempts, tools, v1t, v1d, v2t, v2d = meta
    tool_list = ", ".join(f"SafeTool.{tool}" for tool in tools)
    journals = []
    for index, journal in enumerate(level.journals):
        guess = re.match(r"^\d+", journal).group(0)  # type: ignore[union-attr]
        imp_line = ",\n        important: true" if index == 0 else ""
        journals.append(
            f"      _m(\n        'Журнал {guess}',\n        '{dart_string(journal)}'{imp_line}\n      ),"
        )
    logic = [f"      _l('Ограничение', '{dart_string(r)}')," for r in level.restrictions]
    return f"""  Level(
    id: {level.id},
    title: '{dart_string(title)}',
    difficulty: LevelDifficulty.{difficulty},
    codeLength: {len(level.code)},
    correctCode: '{level.code}',
    maxAttempts: {max_attempts},
    logicalClues: [
{chr(10).join(journals + logic)}
    ],
    visualClues: [
      _v('{dart_string(v1t)}', '{dart_string(v1d)}'),
      _v('{dart_string(v2t)}', '{dart_string(v2d)}'),
    ],
    availableTools: [{tool_list}],
    softHint: '{dart_string(HINTS[level.pattern])}',
    solutionExplanation:
        '{dart_string(explain(level))}',
  )"""


def main() -> None:
    levels = [build_forced_level(i, code, FORCED_PATTERNS[i]) for i, code in enumerate(CODES, start=1)]
    header = ORIGINAL.split("final List<Level> allLevels = [", 1)[0] + "final List<Level> allLevels = [\n"
    body = ",\n".join(render_level(lv, LEVEL_META[i - 1]) for i, lv in enumerate(levels, start=1))
    Path("/workspace/Safe-code/lib/data/levels.dart").write_text(header + body + "\n];\n", encoding="utf-8")
    print("Wrote levels.dart")
    from collections import Counter
    c = Counter(lv.pattern for lv in levels)
    for pattern, count in sorted(c.items(), key=lambda x: -x[1]):
        print(f"  {pattern}: {count}")


if __name__ == "__main__":
    main()
