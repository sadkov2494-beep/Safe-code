import 'package:flutter/material.dart';

import '../models/safe_scene.dart';

class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({
    super.key,
    required this.scene,
    required this.child,
    this.badge,
  });

  final SafeScene scene;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [scene.start, scene.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: scene.accent.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: scene.accent.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _ScenePainter(scene: scene)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: scene.accent.withValues(alpha: 0.2),
                        ),
                        child: Icon(scene.icon, color: scene.accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scene.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              scene.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.74),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        _SceneBadge(text: badge!, color: scene.accent),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneBadge extends StatelessWidget {
  const _SceneBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.scene});

  final SafeScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [scene.accent.withValues(alpha: 0.24), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.76, size.height * 0.22),
              radius: size.width * 0.54,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.22),
      size.width * 0.54,
      glowPaint,
    );

    switch (scene.kind) {
      case SafeSceneKind.archive:
        _drawArchive(canvas, size);
      case SafeSceneKind.serverRoom:
        _drawServerRoom(canvas, size);
      case SafeSceneKind.warehouse:
        _drawWarehouse(canvas, size);
      case SafeSceneKind.elevator:
        _drawElevator(canvas, size);
      case SafeSceneKind.container:
        _drawContainer(canvas, size);
    }
  }

  void _drawArchive(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scene.accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var x = 18.0; x < size.width; x += 46) {
      canvas.drawRect(Rect.fromLTWH(x, 86, 30, size.height - 110), paint);
      for (var y = 102.0; y < size.height - 30; y += 22) {
        canvas.drawLine(Offset(x + 4, y), Offset(x + 26, y), paint);
      }
    }
  }

  void _drawServerRoom(Canvas canvas, Size size) {
    final rackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final ledPaint = Paint()..color = scene.accent.withValues(alpha: 0.56);
    for (var x = 14.0; x < size.width; x += 58) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 80, 42, size.height - 104),
          const Radius.circular(8),
        ),
        rackPaint,
      );
      for (var y = 98.0; y < size.height - 36; y += 26) {
        canvas.drawCircle(Offset(x + 10, y), 2.2, ledPaint);
        canvas.drawLine(Offset(x + 18, y), Offset(x + 34, y), rackPaint);
      }
    }
  }

  void _drawWarehouse(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = scene.accent.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 5; col++) {
        final left = 14 + col * 62.0 + (row.isOdd ? 18 : 0);
        final top = size.height - 54 - row * 38.0;
        canvas.drawRect(Rect.fromLTWH(left, top, 44, 30), boxPaint);
        canvas.drawLine(
          Offset(left, top),
          Offset(left + 44, top + 30),
          boxPaint,
        );
      }
    }
  }

  void _drawElevator(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = scene.accent.withValues(alpha: 0.13)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.5, 78),
      Offset(size.width * 0.5, size.height),
      linePaint,
    );
    for (var y = 92.0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      _drawNumber(canvas, Offset(size.width - 34, y + 10), '${(y ~/ 34) % 9}');
    }
  }

  void _drawContainer(Canvas canvas, Size size) {
    final ribPaint = Paint()
      ..color = scene.accent.withValues(alpha: 0.14)
      ..strokeWidth = 2;
    for (var x = -20.0; x < size.width + 20; x += 34) {
      canvas.drawLine(Offset(x, 80), Offset(x + 32, size.height), ribPaint);
    }
    final platePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 118, size.height - 54, 92, 30),
        const Radius.circular(8),
      ),
      platePaint,
    );
    _drawNumber(canvas, Offset(size.width - 72, size.height - 39), 'CARGO');
  }

  void _drawNumber(Canvas canvas, Offset center, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.18),
          fontSize: text.length > 2 ? 12 : 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) {
    return oldDelegate.scene != scene;
  }
}
