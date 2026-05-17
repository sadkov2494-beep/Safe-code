import 'package:flutter/material.dart';

class SafeWidget extends StatelessWidget {
  const SafeWidget({
    super.key,
    required this.input,
    required this.codeLength,
    required this.isOpen,
    required this.status,
  });

  final String input;
  final int codeLength;
  final bool isOpen;
  final InputStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = switch (status) {
      InputStatus.idle => colorScheme.primary,
      InputStatus.correct => Colors.greenAccent,
      InputStatus.wrong => colorScheme.error,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.green.shade900, colorScheme.surfaceContainerHighest]
              : [colorScheme.surfaceContainerHighest, colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isOpen ? 0.45 : 0.22),
            blurRadius: isOpen ? 34 : 18,
            spreadRadius: isOpen ? 4 : 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedRotation(
                turns: isOpen ? 0.08 : 0,
                duration: const Duration(milliseconds: 450),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 7),
                  ),
                  child: Icon(
                    isOpen ? Icons.lock_open : Icons.lock,
                    color: statusColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen ? 'Сейф открыт' : 'Цифровая панель',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Следы, журналы и ограничения указывают на единственный код.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(codeLength, (index) {
              final hasDigit = index < input.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 42,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasDigit ? statusColor : colorScheme.outlineVariant,
                    width: 2,
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.62),
                ),
                child: Text(
                  hasDigit ? input[index] : '•',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 1.5,
                    color: hasDigit ? statusColor : colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum InputStatus { idle, correct, wrong }
