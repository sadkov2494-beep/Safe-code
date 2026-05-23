import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.lock_outline,
        'Выберите сейф',
        'Уровни открываются последовательно. Пройденные сейфы можно переигрывать ради лучшего результата.',
      ),
      (
        Icons.fact_check_outlined,
        'Поймите журналы',
        'Вы аналитик Safe Code. Журналы сняты из сервисной памяти панели: это обезличенные старые попытки, по которым контроллер сообщает совпадения.',
      ),
      (
        Icons.visibility_outlined,
        'Сверьте физические улики',
        'На самих цифрах появляются только реальные следы: отпечатки, тепло, царапины, потертости и пыль. Записки и журналы лежат в досье.',
      ),
      (
        Icons.map_outlined,
        'Смотрите на сцену',
        'Архив, серверная, склад, лифт и контейнер помогают отличать дела визуально и задают атмосферу сейфа.',
      ),
      (
        Icons.edit_note_outlined,
        'Ведите блокнот',
        'Внутри уровня отмечайте цифры как возможные, исключенные или подтвержденные. Заметки сохраняются для сейфа.',
      ),
      (
        Icons.build_outlined,
        'Используйте инструменты',
        'Сканер, тепловизор, дешифратор, анализатор и прослушка работают бесплатно в MVP.',
      ),
      (
        Icons.today_outlined,
        'Возвращайтесь за Daily',
        'Каждый день создается уникальный сейф дня. Открытые сейфы попадают в коллекцию.',
      ),
      (
        Icons.star_outline,
        'Берегите звезды',
        '3 звезды выдаются без ошибок и помощи; одна ошибка или помощь дают 2 звезды; больше — 1 звезду.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Обучение')),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: steps.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(child: Icon(step.$1)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(step.$3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
