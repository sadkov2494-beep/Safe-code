import 'package:flutter/material.dart';

enum SafePanelPattern { grid, diagonal, circuit, rings, blueprint, dotMatrix }

class LevelVisualTheme {
  const LevelVisualTheme({
    required this.levelId,
    required this.name,
    required this.modelCode,
    required this.lockLabel,
    required this.accent,
    required this.start,
    required this.end,
    required this.pattern,
  });

  final int levelId;
  final String name;
  final String modelCode;
  final String lockLabel;
  final Color accent;
  final Color start;
  final Color end;
  final SafePanelPattern pattern;
}
