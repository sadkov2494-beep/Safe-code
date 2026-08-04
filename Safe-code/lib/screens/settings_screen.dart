import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_release_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.onThemeChanged,
    required this.onSoundChanged,
    required this.onMusicChanged,
  });

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool musicEnabled;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Future<void> Function(bool enabled) onSoundChanged;
  final Future<void> Function(bool enabled) onMusicChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled = widget.soundEnabled;
  late bool _musicEnabled = widget.musicEnabled;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() => _packageInfo = info);
  }

  Future<void> _openUpdatePage() async {
    final uri = Uri.parse(AppReleaseConfig.releasesPageUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть страницу обновлений.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.themeMode == ThemeMode.light;
    final versionLabel = _packageInfo == null
        ? 'Загрузка...'
        : '${_packageInfo!.version} (${_packageInfo!.buildNumber})';

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.system_update_alt_outlined),
              title: const Text('Версия приложения'),
              subtitle: Text(
                '$versionLabel\n'
                'Обновления из RuStore и с GitHub — разные каналы: нужен тот же источник, '
                'с которого ставили игру. RuStore-версию обновляйте только через магазин.',
              ),
              trailing: FilledButton.tonal(
                onPressed: _openUpdatePage,
                child: const Text('Обновить'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.light_mode_outlined),
              title: const Text('Светлая тема'),
              subtitle: const Text(
                'Темная тема остается режимом по умолчанию.',
              ),
              value: isLight,
              onChanged: (value) => widget.onThemeChanged(
                value ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('Звуковые эффекты'),
              subtitle: const Text(
                'Щелчки клавиш, ошибка, подсказка и открытие сейфа.',
              ),
              value: _soundEnabled,
              onChanged: (value) async {
                setState(() => _soundEnabled = value);
                await widget.onSoundChanged(value);
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.music_note_outlined),
              title: const Text('Фоновая атмосфера'),
              subtitle: const Text(
                'Тихий looping ambient для меню и игровых сцен.',
              ),
              value: _musicEnabled,
              onChanged: (value) async {
                setState(() => _musicEnabled = value);
                await widget.onMusicChanged(value);
              },
            ),
          ),
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
                'Yandex Ads SDK подключен: rewarded ads и interstitial используют тестовые demo ID до релиза.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
