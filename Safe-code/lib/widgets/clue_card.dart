import 'package:flutter/material.dart';

import '../models/clue.dart';

class ClueCard extends StatefulWidget {
  const ClueCard({super.key, required this.clue, this.highlighted = false});

  final Clue clue;
  final bool highlighted;

  @override
  State<ClueCard> createState() => _ClueCardState();
}

class _ClueCardState extends State<ClueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.highlighted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ClueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlighted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.highlighted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, label) = switch (widget.clue.type) {
      ClueType.mastermind => (Icons.fact_check_outlined, 'Журнал'),
      ClueType.logic => (Icons.rule_folder_outlined, 'Логика'),
      ClueType.visual => (Icons.visibility_outlined, 'Улика'),
    };

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = widget.highlighted ? _pulseController.value : 0.0;
        return AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: widget.highlighted ? 1.015 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.highlighted
                    ? Color.lerp(
                        colorScheme.primary,
                        Colors.white,
                        pulse * 0.35,
                      )!
                    : colorScheme.outlineVariant,
                width: widget.highlighted ? 2 : 1,
              ),
              color: widget.highlighted
                  ? colorScheme.primaryContainer.withValues(
                      alpha: 0.18 + pulse * 0.08,
                    )
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              boxShadow: widget.highlighted
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(
                          alpha: 0.18 + pulse * 0.12,
                        ),
                        blurRadius: 18 + pulse * 10,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  if (widget.highlighted)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ClueScanPainter(
                          color: colorScheme.primary,
                          progress: pulse,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: Icon(
                      icon,
                      color: widget.highlighted ? colorScheme.primary : null,
                    ),
                    title: Text(widget.clue.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('$label • ${widget.clue.description}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClueScanPainter extends CustomPainter {
  const _ClueScanPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Rect.fromLTWH(x - 34, 0, 68, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ClueScanPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
