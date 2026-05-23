import '../models/clue.dart';
import '../models/level.dart';
import '../models/safe_tool.dart';

Clue _m(String title, String description, {bool important = false}) {
  return Clue(
    title: title,
    description: description,
    type: ClueType.mastermind,
    isImportant: important,
  );
}

Clue _l(String title, String description, {bool important = false}) {
  return Clue(
    title: title,
    description: description,
    type: ClueType.logic,
    isImportant: important,
  );
}

Clue _v(String title, String description, {bool important = false}) {
  return Clue(
    title: title,
    description: description,
    type: ClueType.visual,
    isImportant: important,
  );
}

final List<Level> allLevels = [
  Level(
    id: 1,
    title: 'Архивный ящик',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '482',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 482',
        '482: все три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 129', '129: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Цифры не повторяются, сумма цифр равна 14.'),
    ],
    visualClues: [
      _v(
        'Стертые кнопки',
        'На клавишах 4 и 8 матовая поверхность стерта сильнее.',
      ),
      _v('Тепловой след', 'Слабое тепло осталось на нижней правой клавише 2.'),
    ],
    availableTools: [SafeTool.fingerprintScanner, SafeTool.decryptor],
    softHint: 'Проверь запись с полным совпадением и подтверди ее суммой цифр.',
    solutionExplanation:
        'Запись 482 дает три точных совпадения. Сумма 4+8+2 равна 14, визуальные следы подтверждают эти клавиши.',
  ),
  Level(
    id: 2,
    title: 'Пыльная панель',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '157',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 123',
        '123: одна цифра верна и стоит на своем месте.',
        important: true,
      ),
      _m('Журнал 570', '570: две цифры верны, но стоят не на своих местах.'),
      _l('Ограничение', 'Последняя цифра больше первой, цифры не повторяются.'),
    ],
    visualClues: [
      _v('Отпечаток', 'На 7 виден свежий отпечаток у правого края.'),
      _v('Записка', 'На записке указано: "середина меньше краев".'),
    ],
    availableTools: [SafeTool.fingerprintScanner, SafeTool.thermalViewer],
    softHint: 'В записи 123 точной может быть только первая позиция.',
    solutionExplanation:
        'Из 123 точной остается 1 на первой позиции. В 570 верны 5 и 7, но они переставлены, значит код 157.',
  ),
  Level(
    id: 3,
    title: 'Нулевой след',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '630',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 603',
        '603: все три цифры входят в код, одна стоит на своем месте.',
        important: true,
      ),
      _m('Журнал 918', '918: ни одной верной цифры.'),
      _l(
        'Ограничение',
        'Первая цифра четная, средняя цифра ровно вдвое меньше первой.',
      ),
    ],
    visualClues: [
      _v('Царапина', 'Царапина начинается возле 6 и тянется к центру панели.'),
      _v('Пятно пыли', 'Кнопка 0 чище соседних клавиш.'),
    ],
    availableTools: [SafeTool.decryptor, SafeTool.analyzer],
    softHint:
        'В журнале 603 на месте стоит только первая цифра; 0 уходит в конец.',
    solutionExplanation:
        '918 исключает 9,1,8. В 603 все цифры входят в код, но на месте только 6. Ограничение делает середину равной половине 6, то есть 3, а 0 остается последним: 630.',
  ),
  Level(
    id: 4,
    title: 'Латунный замок',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '294',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 204',
        '204: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 981', '981: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Сумма цифр равна 15, последняя цифра четная.'),
    ],
    visualClues: [
      _v('Стертый угол', 'У клавиши 9 стерта верхняя грань.'),
      _v('Записка', 'На листке рядом написано: "края уже почти на месте".'),
    ],
    availableTools: [SafeTool.thermalViewer, SafeTool.stethoscope],
    softHint: 'Края из 204 совпадают, а недостающую середину дает сумма.',
    solutionExplanation:
        'В 204 точны 2 и 4 на краях. Чтобы сумма была 15, в середине должна стоять 9: код 294.',
  ),
  Level(
    id: 5,
    title: 'Тихий коридор',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '718',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 728',
        '728: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 105', '105: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Код содержит ровно две нечетные цифры.'),
    ],
    visualClues: [
      _v(
        'Тепловой след',
        'На 8 сохранился самый яркий след последнего нажатия.',
      ),
      _v('Папка улик', 'В папке выделены цифры 7, 1 и 8.'),
    ],
    availableTools: [SafeTool.fingerprintScanner, SafeTool.analyzer],
    softHint: 'В записи 728 уже зафиксированы первая и последняя позиции.',
    solutionExplanation:
        'Подсказка 728 фиксирует 7 и 8. Из 105 входит только 1 не на первой позиции, значит она занимает середину.',
  ),
  Level(
    id: 6,
    title: 'Слабая лампа',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '365',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 345',
        '345: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 760', '760: одна цифра верна и стоит на своем месте.'),
      _l('Ограничение', 'Средняя цифра равна сумме крайних минус 2.'),
    ],
    visualClues: [
      _v('Отпечаток', 'На 6 найден отпечаток в центре панели.'),
      _v(
        'Потертая кнопка',
        'Клавиша 5 нажималась чаще остальных в нижнем ряду.',
      ),
    ],
    availableTools: [SafeTool.thermalViewer, SafeTool.decryptor],
    softHint: 'Середина не 4: журнал 760 указывает на 6 в центральной позиции.',
    solutionExplanation:
        'В 345 точны 3 и 5. Из 760 верна 6, и она стоит на своем месте в середине: 365.',
  ),
  Level(
    id: 7,
    title: 'Северный сейф',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '941',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 741',
        '741: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 903', '903: одна цифра верна и стоит на своем месте.'),
      _l('Ограничение', 'Последняя цифра меньше первой, цифры не повторяются.'),
    ],
    visualClues: [
      _v('Записка', 'На стикере: "начинается с самой большой улики".'),
      _v('Царапины', 'Царапины рядом с 9 заметно глубже остальных.'),
    ],
    availableTools: [SafeTool.fingerprintScanner, SafeTool.stethoscope],
    softHint: 'Совмести последнюю позицию из 741 с первой из 903.',
    solutionExplanation:
        'Журнал 741 фиксирует 4 и 1 на второй и третьей позициях. 903 дает 9 на первой позиции, поэтому код 941.',
  ),
  Level(
    id: 8,
    title: 'Мокрый бетон',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '520',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 521',
        '521: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 908', '908: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Сумма цифр равна 7.'),
    ],
    visualClues: [
      _v('Тепловизор охраны', 'В журнале тепла видна нулевая клавиша.'),
      _v('Пыль', 'На 5 и 2 нет свежей пыли после нажатия.'),
    ],
    availableTools: [SafeTool.thermalViewer, SafeTool.decryptor],
    softHint: 'Первые две позиции уже известны; сумма подсказывает последнюю.',
    solutionExplanation:
        'Из 521 точны 5 и 2. При сумме 7 третья цифра должна быть 0, что согласуется с 908.',
  ),
  Level(
    id: 9,
    title: 'Синяя подсветка',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '806',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 806',
        '806: все три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 135', '135: ни одной верной цифры.'),
      _l('Ограничение', 'Первая цифра больше последней, середина равна нулю.'),
    ],
    visualClues: [
      _v('Светодиод', 'Подсветка вокруг 0 ярче в центральной ячейке.'),
      _v('Стертые кнопки', '8 и 6 выглядят недавно очищенными.'),
    ],
    availableTools: [SafeTool.analyzer, SafeTool.stethoscope],
    softHint: 'Центральная ячейка — ключ к проверке записи.',
    solutionExplanation:
        'Запись 806 полностью совпадает, а ограничения и визуальные следы только подтверждают порядок.',
  ),
  Level(
    id: 10,
    title: 'Красная папка',
    difficulty: LevelDifficulty.easy,
    codeLength: 3,
    correctCode: '273',
    maxAttempts: 5,
    logicalClues: [
      _m(
        'Журнал 293',
        '293: две цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 671', '671: одна цифра верна и стоит на своем месте.'),
      _l('Ограничение', 'Цифры идут не по порядку, сумма равна 12.'),
    ],
    visualClues: [
      _v('Записка', 'В папке подчеркнута фраза: "семь между краями".'),
      _v('Отпечаток', 'На 7 найден частичный отпечаток.'),
    ],
    availableTools: [SafeTool.fingerprintScanner, SafeTool.decryptor],
    softHint: 'Края из 293 остаются, а журнал 671 подтверждает 7 в середине.',
    solutionExplanation:
        '2 и 3 стоят на местах из 293. В журнале 671 верна только 7, и она уже стоит на второй позиции: код 273.',
  ),
  Level(
    id: 11,
    title: 'Стеклянная дверь',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '7392',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 7302',
        '7302: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 1958', '1958: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Сумма цифр равна 21, цифры не повторяются.'),
    ],
    visualClues: [
      _v('Тепловая сетка', 'У второй позиции виден след 3.'),
      _v('Царапина', 'Возле 9 царапина направлена к третьему окну кода.'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.analyzer,
      SafeTool.decryptor,
    ],
    softHint: 'В 7302 ошибается только третья позиция.',
    solutionExplanation:
        '7,3 и 2 фиксируются журналом 7302. Сумма 21 требует третью цифру 9: 7392.',
  ),
  Level(
    id: 12,
    title: 'Комната хранения',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '4816',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 4216',
        '4216: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 8800', '8800: одна цифра верна и стоит на своем месте.'),
      _l('Ограничение', 'Код содержит ровно три четные цифры.'),
    ],
    visualClues: [
      _v('Отпечатки', 'На 4 и 6 остались отчетливые отпечатки.'),
      _v('Стикер', 'Записано: "8 не стоит первым".'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.stethoscope,
      SafeTool.decryptor,
    ],
    softHint: 'Поменять нужно только вторую цифру из 4216.',
    solutionExplanation:
        '4,1,6 стоят на местах. Журнал 8800 показывает, что 8 верна во второй позиции, поэтому код 4816.',
  ),
  Level(
    id: 13,
    title: 'Черная бирка',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '2057',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 2054',
        '2054: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 7810', '7810: две цифры верны, но стоят не на своих местах.'),
      _l(
        'Ограничение',
        'Последняя цифра больше первой, соседние цифры не отличаются на 1.',
      ),
    ],
    visualClues: [
      _v('Тепловой след', 'Последней нажимали 7.'),
      _v('Пыль', '0 очищен только в центральной колонке.'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.analyzer,
      SafeTool.decryptor,
    ],
    softHint:
        'Первые три позиции уже надежны; в 7810 кроме известного 0 спрятана последняя цифра.',
    solutionExplanation:
        '2,0 и 5 фиксируются первой записью. В 7810 верны 0 и 7, но они стоят не на своих местах; 0 уже известен, значит последней цифрой становится 7.',
  ),
  Level(
    id: 14,
    title: 'Лифт без звука',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '9631',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 9630',
        '9630: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 2418', '2418: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Первая цифра нечетная, сумма цифр равна 19.'),
    ],
    visualClues: [
      _v('Прослушка', 'Самый чистый щелчок слышен на 1.'),
      _v('Папка', 'В старой попытке зачеркнут ноль на конце.'),
    ],
    availableTools: [
      SafeTool.stethoscope,
      SafeTool.analyzer,
      SafeTool.fingerprintScanner,
    ],
    softHint: 'Ноль в конце первой записи заменяется цифрой из второй записи.',
    solutionExplanation:
        '9,6,3 стоят верно. Сумма 19 требует 1 на последней позиции, что совпадает с журналом 2418.',
  ),
  Level(
    id: 15,
    title: 'Файл "Север"',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '1478',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 1470',
        '1470: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 5806', '5806: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Цифры идут по возрастанию.'),
    ],
    visualClues: [
      _v('Записка', 'На записке: "лестница заканчивается четной цифрой".'),
      _v('Стертая клавиша', '8 выглядит свежее остальных четных кнопок.'),
    ],
    availableTools: [
      SafeTool.decryptor,
      SafeTool.thermalViewer,
      SafeTool.analyzer,
    ],
    softHint: 'Последняя цифра должна продолжить возрастающую цепочку.',
    solutionExplanation:
        'Первые три цифры 1,4,7 стоят верно. Возрастание и журнал 5806 указывают на 8 в конце.',
  ),
  Level(
    id: 16,
    title: 'Пульт охраны',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '6204',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 6209',
        '6209: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 3145', '3145: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Код содержит три ненулевые четные цифры и один ноль.'),
    ],
    visualClues: [
      _v('Отпечаток', 'На 4 отпечаток частично закрыт пылью.'),
      _v('Тепло', 'Ноль недавно нажимался в третьей позиции.'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.thermalViewer,
      SafeTool.decryptor,
    ],
    softHint: 'Первые три позиции из 6209 не меняются.',
    solutionExplanation:
        '6,2,0 фиксируются первой записью. Из 3145 входит 4, но не на третьей позиции, значит она последняя.',
  ),
  Level(
    id: 17,
    title: 'Запертый стеллаж',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '5829',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 5820',
        '5820: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9017', '9017: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Последняя цифра больше первой.'),
    ],
    visualClues: [
      _v('Царапины', 'Около 9 видны две параллельные царапины.'),
      _v('Журнал', 'В старой записи 0 на конце помечен как ложный.'),
    ],
    availableTools: [
      SafeTool.analyzer,
      SafeTool.stethoscope,
      SafeTool.decryptor,
    ],
    softHint: 'Вторая запись дает 9, но показывает, что она не первая.',
    solutionExplanation:
        '5,8,2 стоят верно. В 9017 входит только 9, но не на первой позиции записи; свободной остается последняя позиция: 5829.',
  ),
  Level(
    id: 18,
    title: 'Серый планшет',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '3140',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 3148',
        '3148: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9062', '9062: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Последняя цифра меньше первой.'),
    ],
    visualClues: [
      _v('Тепло', '0 хранит слабый след на правом краю панели.'),
      _v('Записка', 'Заметка: "конец холодный и круглый".'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.fingerprintScanner,
      SafeTool.decryptor,
    ],
    softHint: 'Заменить нужно только последнюю цифру.',
    solutionExplanation:
        '3,1,4 подтверждены первой записью. Из 9062 входит только 0, и он должен стоять в конце: 3140.',
  ),
  Level(
    id: 19,
    title: 'Пятый контейнер',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '8762',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 8760',
        '8760: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 2419', '2419: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Цифры идут по убыванию до последней пары.'),
    ],
    visualClues: [
      _v('Пыль', 'На 2 нет налета, словно ее нажали последней.'),
      _v('Стикер', 'Подсказка на стикере: "нижний левый финал".'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.stethoscope,
      SafeTool.analyzer,
    ],
    softHint: 'Вторая запись дает 2, но не в первом окне.',
    solutionExplanation:
        'Первые три цифры 8,7,6 верны. В 2419 входит только 2, но не на первой позиции записи; свободный финальный слот дает код 8762.',
  ),
  Level(
    id: 20,
    title: 'Сейф с меткой',
    difficulty: LevelDifficulty.medium,
    codeLength: 4,
    correctCode: '4591',
    maxAttempts: 6,
    logicalClues: [
      _m(
        'Журнал 4501',
        '4501: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9876', '9876: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Сумма цифр равна 19, цифры не повторяются.'),
    ],
    visualClues: [
      _v('Царапина', 'Около 9 виден короткий вертикальный след.'),
      _v('Журнал', 'Ноль в третьей позиции помечен красной точкой как ошибка.'),
    ],
    availableTools: [
      SafeTool.decryptor,
      SafeTool.thermalViewer,
      SafeTool.analyzer,
    ],
    softHint: 'Позиции 1, 2 и 4 уже совпадают; сумма раскрывает третью.',
    solutionExplanation:
        '4,5 и 1 стоят на местах. Чтобы получить сумму 19, третья цифра должна быть 9.',
  ),
  Level(
    id: 21,
    title: 'Двойной протокол',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '72836',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 72830',
        '72830: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m(
        'Журнал 60419',
        '60419: одна цифра верна, но стоит не на своем месте.',
      ),
      _l(
        'Ограничение',
        'Сумма цифр равна 26, соседние цифры не отличаются на 1.',
      ),
    ],
    visualClues: [
      _v('Прослушка', 'Самый мягкий щелчок дает последняя клавиша 6.'),
      _v('Тепло', 'Тепловая дуга идет от 7 к 6 через центр панели.'),
    ],
    availableTools: [
      SafeTool.stethoscope,
      SafeTool.analyzer,
      SafeTool.thermalViewer,
    ],
    softHint: 'Первые четыре позиции надежны; последнюю найди по сумме.',
    solutionExplanation:
        '7,2,8,3 уже стоят верно. Сумма 26 оставляет в конце 6, что подтверждается второй записью.',
  ),
  Level(
    id: 22,
    title: 'Зал с отражением',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '93047',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 93041',
        '93041: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 76028', '76028: две цифры верны, одна стоит на своем месте.'),
      _l('Ограничение', 'Последняя цифра больше второй, в коде один ноль.'),
    ],
    visualClues: [
      _v('Отпечаток', 'На 7 найден отпечаток с правой стороны панели.'),
      _v('Записка', 'Запись на полях: "отражение заканчивает код".'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.decryptor,
      SafeTool.analyzer,
    ],
    softHint:
        'Последняя цифра должна быть больше 3 и согласоваться с журналом 76028.',
    solutionExplanation:
        'Первые четыре позиции 9,3,0,4 закреплены. В 76028 верны 0 и 7; 0 уже стоит на третьей позиции, поэтому 7 занимает последний слот.',
  ),
  Level(
    id: 23,
    title: 'Короткий импульс',
    difficulty: LevelDifficulty.hard,
    codeLength: 4,
    correctCode: '1649',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 1640',
        '1640: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9087', '9087: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Ровно две цифры нечетные, сумма равна 20.'),
    ],
    visualClues: [
      _v('Прослушка', 'У 9 самый глубокий щелчок из правого столбца.'),
      _v('Пыль', 'На 0 в журнале виден слой пыли: его не нажимали.'),
    ],
    availableTools: [
      SafeTool.stethoscope,
      SafeTool.analyzer,
      SafeTool.decryptor,
    ],
    softHint: 'Три первые позиции уже верны; сумма заменяет ноль.',
    solutionExplanation:
        '1,6,4 фиксируются. До суммы 20 не хватает 9, значит финальный код 1649.',
  ),
  Level(
    id: 24,
    title: 'Пять контактов',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '85204',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 85209',
        '85209: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 4317', '4317: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'В коде три ненулевые четные цифры и один ноль.'),
    ],
    visualClues: [
      _v('Стертая клавиша', '4 стерта у нижнего края, но не была первой.'),
      _v('Тепло', '0 оставил холодный провал в четвертой позиции.'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.fingerprintScanner,
      SafeTool.decryptor,
    ],
    softHint: 'Пятая позиция не 9; ищи единственную цифру из журнала 4317.',
    solutionExplanation:
        '8,5,2,0 стоят верно. Журнал 4317 дает 4 как входящую цифру, поэтому она закрывает код.',
  ),
  Level(
    id: 25,
    title: 'Узел питания',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '40738',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 40730',
        '40730: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 8612', '8612: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Первая цифра четная, последняя больше первой.'),
    ],
    visualClues: [
      _v('Записка', 'На обороте: "конец выше начала".'),
      _v('Отпечаток', 'На 8 заметен частичный отпечаток большого пальца.'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.analyzer,
      SafeTool.stethoscope,
    ],
    softHint: 'Последняя цифра должна прийти из второй записи и быть больше 4.',
    solutionExplanation:
        '4,0,7,3 уже стоят верно. Из 8612 подходит 8, и ограничение подтверждает, что она последняя.',
  ),
  Level(
    id: 26,
    title: 'Складская метка',
    difficulty: LevelDifficulty.hard,
    codeLength: 4,
    correctCode: '2916',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 2016',
        '2016: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9870', '9870: одна цифра верна, но стоит не на своем месте.'),
      _l(
        'Ограничение',
        'Сумма цифр равна 18, соседние цифры не отличаются на 1.',
      ),
    ],
    visualClues: [
      _v('Царапина', 'Царапина у 9 идет к второму окну.'),
      _v('Журнал', 'Ноль во второй позиции перечеркнут дважды.'),
    ],
    availableTools: [
      SafeTool.decryptor,
      SafeTool.thermalViewer,
      SafeTool.analyzer,
    ],
    softHint: 'В 2016 меняется только вторая цифра.',
    solutionExplanation:
        '2,1,6 фиксируются на своих позициях. Сумма 18 требует 9 во втором окне: 2916.',
  ),
  Level(
    id: 27,
    title: 'Глухой механизм',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '68025',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 68020',
        '68020: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 5174', '5174: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Последняя цифра нечетная, в коде один ноль.'),
    ],
    visualClues: [
      _v('Прослушка', 'У 5 слышен короткий сухой щелчок.'),
      _v('Пыль', 'На последней ячейке есть след округлой кнопки.'),
    ],
    availableTools: [
      SafeTool.stethoscope,
      SafeTool.fingerprintScanner,
      SafeTool.decryptor,
    ],
    softHint: 'Последняя цифра не может быть нулем.',
    solutionExplanation:
        '6,8,0,2 стоят верно. Из 5174 входит 5; нечетность последней позиции приводит к 68025.',
  ),
  Level(
    id: 28,
    title: 'Темный дисплей',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '73519',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 73510',
        '73510: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 9024', '9024: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Все цифры кода нечетные.'),
    ],
    visualClues: [
      _v('Тепло', '9 оставляет след рядом с правым краем дисплея.'),
      _v('Записка', 'На листе: "последняя улика самая высокая".'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.analyzer,
      SafeTool.stethoscope,
    ],
    softHint: 'Последняя позиция не ноль; проверь журнал 9024.',
    solutionExplanation:
        '7,3,5,1 уже стоят верно. Единственная подходящая цифра из 9024 — 9, она закрывает код.',
  ),
  Level(
    id: 29,
    title: 'Медная рамка',
    difficulty: LevelDifficulty.hard,
    codeLength: 4,
    correctCode: '9240',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 9246',
        '9246: три цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 7051', '7051: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Последняя цифра меньше первой, сумма цифр равна 15.'),
    ],
    visualClues: [
      _v('Тепловой след', 'Нулевая клавиша холоднее, но недавно нажималась.'),
      _v('Папка', 'В папке указано: "финал — пустой круг".'),
    ],
    availableTools: [
      SafeTool.thermalViewer,
      SafeTool.decryptor,
      SafeTool.analyzer,
    ],
    softHint: 'Первые три позиции верны, а сумма исключает 6.',
    solutionExplanation:
        '9,2,4 фиксируются. Чтобы сумма была 15, последняя цифра равна 0: 9240.',
  ),
  Level(
    id: 30,
    title: 'Последняя ячейка',
    difficulty: LevelDifficulty.hard,
    codeLength: 5,
    correctCode: '58147',
    maxAttempts: 7,
    logicalClues: [
      _m(
        'Журнал 58140',
        '58140: четыре цифры верны и стоят на своих местах.',
        important: true,
      ),
      _m('Журнал 7602', '7602: одна цифра верна, но стоит не на своем месте.'),
      _l('Ограничение', 'Последняя цифра больше первой, цифры не повторяются.'),
    ],
    visualClues: [
      _v('Отпечаток', 'На 7 виден самый четкий отпечаток из всех следов.'),
      _v('Сейф', 'Под последней ячейкой горит слабая зеленая подсветка.'),
    ],
    availableTools: [
      SafeTool.fingerprintScanner,
      SafeTool.stethoscope,
      SafeTool.analyzer,
    ],
    softHint:
        'Финальная цифра приходит из второй записи и должна быть больше 5.',
    solutionExplanation:
        '5,8,1,4 стоят верно. Из 7602 подходит 7, и ограничение ставит ее в последний слот.',
  ),
];
