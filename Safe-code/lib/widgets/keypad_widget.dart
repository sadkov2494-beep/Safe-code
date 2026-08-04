import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/panel_mark.dart';

class KeypadWidget extends StatefulWidget {
  const KeypadWidget({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
    required this.canSubmit,
    this.visualMarks = const {},
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final bool canSubmit;
  final Map<String, List<PanelMark>> visualMarks;

  @override
  State<KeypadWidget> createState() => _KeypadWidgetState();
}

class _KeypadWidgetState extends State<KeypadWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

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

    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, _) {
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
            final enabled = !isSubmit || widget.canSubmit;
            final marks = widget.visualMarks[label] ?? const <PanelMark>[];
            return FilledButton.tonal(
              onPressed: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      if (isDelete) {
                        widget.onDelete();
                      } else if (isSubmit) {
                        widget.onSubmit();
                      } else {
                        widget.onDigit(label);
                      }
                    }
                  : null,
              child: _MarkedKeyLabel(
                label: label,
                marks: isDelete || isSubmit ? const [] : marks,
                shineValue: (_shineController.value + index * 0.055) % 1,
                shineEnabled: !isDelete && !isSubmit,
              ),
            );
          },
        );
      },
    );
  }
}

class _MarkedKeyLabel extends StatelessWidget {
  const _MarkedKeyLabel({
    required this.label,
    required this.marks,
    required this.shineValue,
    required this.shineEnabled,
  });

  final String label;
  final List<PanelMark> marks;
  final double shineValue;
  final bool shineEnabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final mark in marks) _PanelMarkOverlay(mark: mark),
          if (shineEnabled)
            Positioned.fill(
              child: CustomPaint(
                painter: _KeyShinePainter(progress: shineValue),
              ),
            ),
          Text(label, style: textStyle),
          if (marks.isNotEmpty)
            Positioned(right: 2, top: 0, child: _MarkLegendDots(marks: marks)),
        ],
      ),
    );
  }
}

class _KeyShinePainter extends CustomPainter {
  const _KeyShinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final sweep = (progress * (size.width + size.height * 1.4)) - size.height;
    final path = Path()
      ..moveTo(sweep - 18, size.height)
      ..lineTo(sweep + 2, size.height)
      ..lineTo(sweep + size.height * 0.72, 0)
      ..lineTo(sweep + size.height * 0.72 - 20, 0)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);

    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KeyShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PanelMarkOverlay extends StatelessWidget {
  const _PanelMarkOverlay({required this.mark});

  final PanelMark mark;

  @override
  Widget build(BuildContext context) {
    return switch (mark.type) {
      PanelMarkType.fingerprint => const Positioned(
        left: 5,
        top: 4,
        child: Icon(Icons.fingerprint, size: 34, color: Color(0x88D6E8FF)),
      ),
      PanelMarkType.heat => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.orangeAccent.withValues(alpha: 0.38),
                Colors.deepOrange.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      PanelMarkType.scratch => const Positioned.fill(
        child: CustomPaint(painter: _ScratchPainter()),
      ),
      PanelMarkType.worn => const Positioned.fill(
        child: CustomPaint(painter: _WornPainter()),
      ),
      PanelMarkType.dust => const Positioned.fill(
        child: CustomPaint(painter: _DustPainter()),
      ),
    };
  }
}

class _MarkLegendDots extends StatelessWidget {
  const _MarkLegendDots({required this.marks});

  final List<PanelMark> marks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: marks.take(3).map((mark) {
        final color = switch (mark.type) {
          PanelMarkType.fingerprint => const Color(0xFF90CAF9),
          PanelMarkType.heat => const Color(0xFFFFA726),
          PanelMarkType.scratch => const Color(0xFFCFD8DC),
          PanelMarkType.worn => const Color(0xFFFFF59D),
          PanelMarkType.dust => const Color(0xFFD7CCC8),
        };
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }).toList(),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  const _ScratchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xAAD9E3F0)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.72),
      Offset(size.width * 0.72, size.height * 0.22),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.78),
      Offset(size.width * 0.82, size.height * 0.34),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WornPainter extends CustomPainter {
  const _WornPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88FFF59D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(5, 4, size.width - 10, size.height - 8),
      -0.7,
      2.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DustPainter extends CustomPainter {
  const _DustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x66D7CCC8);
    final points = [
      Offset(size.width * 0.2, size.height * 0.24),
      Offset(size.width * 0.72, size.height * 0.3),
      Offset(size.width * 0.62, size.height * 0.68),
      Offset(size.width * 0.35, size.height * 0.78),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
