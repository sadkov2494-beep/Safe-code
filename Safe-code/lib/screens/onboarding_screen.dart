import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _steps = const [
    _OnboardingStep(
      icon: Icons.badge_outlined,
      title: 'Вы аналитик Safe Code',
      body:
          'Ваша задача - восстановить доступ к сейфам по сервисным журналам, физическим следам и логическим ограничениям.',
      color: Color(0xFF67E8F9),
    ),
    _OnboardingStep(
      icon: Icons.fact_check_outlined,
      title: 'Читайте журналы как доказательства',
      body:
          'Записи вида 482 сообщают, какие цифры входят в код и стоят ли они на своих местах. Не подбирайте вслепую - сопоставляйте факты.',
      color: Color(0xFFFFC857),
    ),
    _OnboardingStep(
      icon: Icons.edit_note_outlined,
      title: 'Ведите блокнот',
      body:
          'Отмечайте цифры как возможные, исключенные или подтвержденные. Блокнот сохраняется для каждого сейфа отдельно.',
      color: Color(0xFFA7F3D0),
    ),
    _OnboardingStep(
      icon: Icons.lock_open_outlined,
      title: 'Откройте первый сейф',
      body:
          'Смотрите на сцену, улики и панель. Чем меньше ошибок и подсказок, тем больше звезд попадет в коллекцию открытых сейфов.',
      color: Color(0xFFA78BFA),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _steps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Брифинг',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Пропустить'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) {
                    return _OnboardingCard(step: _steps[index]);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(_steps.length, (index) {
                    final selected = index == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 6),
                      width: selected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: selected
                            ? _steps[_page].color
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    );
                  }),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      if (isLast) {
                        Navigator.of(context).pop(true);
                        return;
                      }
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    icon: Icon(isLast ? Icons.play_arrow : Icons.arrow_forward),
                    label: Text(isLast ? 'Начать первый сейф' : 'Дальше'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            step.color.withValues(alpha: 0.22),
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: step.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.color.withValues(alpha: 0.18),
              border: Border.all(color: step.color.withValues(alpha: 0.34)),
            ),
            child: Icon(step.icon, color: step.color, size: 54),
          ),
          const SizedBox(height: 26),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Прохождение занимает около 1-2 минут.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: step.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
