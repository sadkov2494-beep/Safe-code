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
        'Соберите логику',
        'Mastermind-записи показывают, какие цифры верны и стоят ли они на своих местах.',
      ),
      (
        Icons.visibility_outlined,
        'Сверьте визуальные улики',
        'Отпечатки, тепловые следы, царапины и заметки помогают убрать невозможные варианты.',
      ),
      (
        Icons.build_outlined,
        'Используйте инструменты',
        'Сканер, тепловизор, дешифратор, анализатор и прослушка работают бесплатно в MVP.',
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
