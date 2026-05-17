import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeypadWidget extends StatelessWidget {
  const KeypadWidget({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
    required this.canSubmit,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '⌫',
      '0',
      '✓',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final label = buttons[index];
        final isSubmit = label == '✓';
        final isDelete = label == '⌫';
        final enabled = !isSubmit || canSubmit;
        return FilledButton.tonal(
          onPressed: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  if (isDelete) {
                    onDelete();
                  } else if (isSubmit) {
                    onSubmit();
                  } else {
                    onDigit(label);
                  }
                }
              : null,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}
