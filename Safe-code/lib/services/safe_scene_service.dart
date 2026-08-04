import 'package:flutter/material.dart';

import '../models/safe_scene.dart';

class SafeSceneService {
  const SafeSceneService();

  static const scenes = [
    SafeScene(
      kind: SafeSceneKind.archive,
      title: 'Архив',
      description: 'Стеллажи с делами, картотека и пыльные лампы за сейфом.',
      accent: Color(0xFF67E8F9),
      start: Color(0xFF102A43),
      end: Color(0xFF07111D),
      icon: Icons.inventory_2_outlined,
    ),
    SafeScene(
      kind: SafeSceneKind.serverRoom,
      title: 'Серверная',
      description:
          'Холодный коридор стоек, мигающие индикаторы и кабельные трассы.',
      accent: Color(0xFF22D3EE),
      start: Color(0xFF062C36),
      end: Color(0xFF061018),
      icon: Icons.dns_outlined,
    ),
    SafeScene(
      kind: SafeSceneKind.warehouse,
      title: 'Склад',
      description:
          'Паллеты, коробки и маркировка отгрузки вокруг панели доступа.',
      accent: Color(0xFFF59E0B),
      start: Color(0xFF3A2408),
      end: Color(0xFF120B04),
      icon: Icons.warehouse_outlined,
    ),
    SafeScene(
      kind: SafeSceneKind.elevator,
      title: 'Лифт',
      description: 'Узкая шахта, этажные метки и аварийная подсветка.',
      accent: Color(0xFFC4B5FD),
      start: Color(0xFF261B3D),
      end: Color(0xFF0D0916),
      icon: Icons.elevator_outlined,
    ),
    SafeScene(
      kind: SafeSceneKind.container,
      title: 'Контейнер',
      description: 'Грузовые ребра металла, пломбы и номерные таблички.',
      accent: Color(0xFFFB923C),
      start: Color(0xFF3B1D0B),
      end: Color(0xFF120805),
      icon: Icons.fire_truck_outlined,
    ),
  ];

  SafeScene sceneForLevel(int levelId) {
    final index = (levelId - 1).abs() % scenes.length;
    return scenes[index];
  }
}
