import 'package:flutter/material.dart';

import '../models/level_visual_theme.dart';

class SafeWidget extends StatelessWidget {
  const SafeWidget({
    super.key,
    required this.input,
    required this.codeLength,
    required this.isOpen,
    required this.status,
    required this.visualTheme,
  });

  final String input;
  final int codeLength;
  final bool isOpen;
  final InputStatus status;
  final LevelVisualTheme visualTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = switch (status) {
      InputStatus.idle => visualTheme.accent,
      InputStatus.correct => Colors.greenAccent,
      InputStatus.wrong => colorScheme.error,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.green.shade900, colorScheme.surfaceContainerHighest]
              : [visualTheme.start, visualTheme.end],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SafePanelPainter(
                  color: statusColor,
                  pattern: visualTheme.pattern,
                  levelId: visualTheme.levelId,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors, size: 18, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        visualTheme.modelCode,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              letterSpacing: 1.6,
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        isOpen ? 'UNLOCKED' : visualTheme.lockLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(codeLength, (index) {
                      final hasDigit = index < input.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 42,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasDigit
                                ? statusColor
                                : colorScheme.outlineVariant,
                            width: 2,
                          ),
                          color: Colors.black.withValues(alpha: 0.22),
                          boxShadow: hasDigit
                              ? [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.28),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          hasDigit ? input[index] : '•',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                letterSpacing: 1.5,
                                color: hasDigit
                                    ? statusColor
                                    : colorScheme.outline,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AnimatedRotation(
                        turns: isOpen ? 0.08 : 0,
                        duration: const Duration(milliseconds: 450),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                statusColor.withValues(alpha: 0.28),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(color: statusColor, width: 6),
                          ),
                          child: Icon(
                            isOpen ? Icons.lock_open : Icons.lock,
                            color: statusColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOpen ? 'Сейф открыт' : visualTheme.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            _DiagnosticGraph(
                              color: statusColor,
                              status: status,
                              filledSlots: input.length,
                              totalSlots: codeLength,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum InputStatus { idle, correct, wrong }

class _DiagnosticGraph extends StatelessWidget {
  const _DiagnosticGraph({
    required this.color,
    required this.status,
    required this.filledSlots,
    required this.totalSlots,
  });

  final Color color;
  final InputStatus status;
  final int filledSlots;
  final int totalSlots;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: CustomPaint(
        painter: _DiagnosticGraphPainter(
          color: color,
          progress: totalSlots == 0 ? 0 : filledSlots / totalSlots,
          status: status,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SafePanelPainter extends CustomPainter {
  const _SafePanelPainter({
    required this.color,
    required this.pattern,
    required this.levelId,
  });

  final Color color;
  final SafePanelPattern pattern;
  final int levelId;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    switch (pattern) {
      case SafePanelPattern.grid:
        for (var x = 0.0; x < size.width; x += 22) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        }
        for (var y = 0.0; y < size.height; y += 22) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
      case SafePanelPattern.diagonal:
        for (var x = -size.height; x < size.width; x += 24) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            gridPaint,
          );
        }
      case SafePanelPattern.circuit:
        _drawCircuit(canvas, size, gridPaint);
      case SafePanelPattern.rings:
        final center = Offset(size.width * 0.74, size.height * 0.42);
        for (var radius = 26.0; radius < size.width * 0.7; radius += 26) {
          canvas.drawCircle(center, radius, gridPaint);
        }
      case SafePanelPattern.blueprint:
        for (var x = 12.0; x < size.width; x += 34) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        }
        for (var y = 12.0; y < size.height; y += 34) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
        canvas.drawLine(
          Offset.zero,
          Offset(size.width, size.height),
          gridPaint,
        );
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(0, size.height),
          gridPaint,
        );
      case SafePanelPattern.dotMatrix:
        final dotPaint = Paint()..color = color.withValues(alpha: 0.09);
        for (var x = 12.0; x < size.width; x += 22) {
          for (var y = 12.0; y < size.height; y += 22) {
            canvas.drawCircle(
              Offset(x, y),
              1.7 + (levelId % 3) * 0.35,
              dotPaint,
            );
          }
        }
    }

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [color.withValues(alpha: 0.22), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.78, size.height * 0.18),
              radius: size.width * 0.45,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      size.width * 0.45,
      glowPaint,
    );
  }

  void _drawCircuit(Canvas canvas, Size size, Paint paint) {
    final offsets = [
      Offset(size.width * 0.1, size.height * 0.24),
      Offset(size.width * 0.36, size.height * 0.24),
      Offset(size.width * 0.36, size.height * 0.48),
      Offset(size.width * 0.62, size.height * 0.48),
      Offset(size.width * 0.62, size.height * 0.72),
      Offset(size.width * 0.88, size.height * 0.72),
    ];
    for (var i = 0; i < offsets.length - 1; i++) {
      canvas.drawLine(offsets[i], offsets[i + 1], paint);
    }
    for (final point in offsets) {
      canvas.drawCircle(point, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SafePanelPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pattern != pattern ||
        oldDelegate.levelId != levelId;
  }
}

class _DiagnosticGraphPainter extends CustomPainter {
  const _DiagnosticGraphPainter({
    required this.color,
    required this.progress,
    required this.status,
  });

  final Color color;
  final double progress;
  final InputStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = color.withValues(alpha: 0.26)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final activePaint = Paint()
      ..color = color.withValues(alpha: 0.82)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    const bars = 12;
    for (var i = 0; i < bars; i++) {
      final x = 10 + i * ((size.width - 20) / (bars - 1));
      final heightFactor = _heightFactor(i);
      final top = size.height - 8 - (size.height - 16) * heightFactor;
      canvas.drawLine(Offset(x, size.height - 8), Offset(x, top), barPaint);
      if (i / (bars - 1) <= progress) {
        canvas.drawLine(
          Offset(x, size.height - 8),
          Offset(x, top),
          activePaint,
        );
      }
    }

    final linePaint = Paint()
      ..color = status == InputStatus.wrong ? Colors.redAccent : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final path = Path();
    for (var i = 0; i < bars; i++) {
      final x = 10 + i * ((size.width - 20) / (bars - 1));
      final y = size.height * (0.58 - _heightFactor(i) * 0.28);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  double _heightFactor(int index) {
    final pattern = [
      0.34,
      0.62,
      0.44,
      0.78,
      0.54,
      0.88,
      0.48,
      0.72,
      0.38,
      0.66,
      0.5,
      0.82,
    ];
    return pattern[index % pattern.length];
  }

  @override
  bool shouldRepaint(covariant _DiagnosticGraphPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.status != status;
  }
}
