import 'package:flutter/material.dart';

enum SafeSceneKind { archive, serverRoom, warehouse, elevator, container }

class SafeScene {
  const SafeScene({
    required this.kind,
    required this.title,
    required this.description,
    required this.accent,
    required this.start,
    required this.end,
    required this.icon,
  });

  final SafeSceneKind kind;
  final String title;
  final String description;
  final Color accent;
  final Color start;
  final Color end;
  final IconData icon;
}
