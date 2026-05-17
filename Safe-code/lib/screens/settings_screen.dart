import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = themeMode == ThemeMode.light;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.light_mode_outlined),
              title: const Text('Светлая тема'),
              subtitle: const Text(
                'Темная тема остается режимом по умолчанию.',
              ),
              value: isLight,
              onChanged: (value) =>
                  onThemeChanged(value ? ThemeMode.light : ThemeMode.dark),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.vibration),
              title: Text('Haptic feedback'),
              subtitle: Text(
                'Системная вибрация используется при вводе, если устройство ее поддерживает.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.ads_click_outlined),
              title: Text('Реклама'),
              subtitle: Text(
                'SDK не подключен. Заглушка AdService подготовлена для rewarded ads.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
