import 'package:flutter/material.dart';

import 'models/player_progress.dart';
import 'screens/main_menu_screen.dart';
import 'services/level_service.dart';
import 'services/progress_service.dart';

class SafeCodeApp extends StatefulWidget {
  const SafeCodeApp({super.key});

  @override
  State<SafeCodeApp> createState() => _SafeCodeAppState();
}

class _SafeCodeAppState extends State<SafeCodeApp> {
  final _progressService = const ProgressService();
  final _levelService = const LevelService();

  ThemeMode _themeMode = ThemeMode.dark;
  PlayerProgress _progress = PlayerProgress.empty();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final progress = await _progressService.loadProgress();
    final themeMode = await _progressService.loadThemeMode();
    final soundEnabled = await _progressService.loadSoundEnabled();
    final musicEnabled = await _progressService.loadMusicEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _progress = progress;
      _themeMode = themeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
      _soundEnabled = soundEnabled;
      _musicEnabled = musicEnabled;
      _isLoading = false;
    });
  }

  Future<void> _refreshProgress() async {
    final progress = await _progressService.loadProgress();
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await _progressService.saveThemeMode(
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    if (!mounted) {
      return;
    }
    setState(() => _themeMode = mode);
  }

  Future<void> _setSoundEnabled(bool enabled) async {
    await _progressService.saveSoundEnabled(enabled);
    if (!mounted) {
      return;
    }
    setState(() => _soundEnabled = enabled);
  }

  Future<void> _setMusicEnabled(bool enabled) async {
    await _progressService.saveMusicEnabled(enabled);
    if (!mounted) {
      return;
    }
    setState(() => _musicEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Code',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: _isLoading
          ? const _BootScreen()
          : MainMenuScreen(
              levelService: _levelService,
              progressService: _progressService,
              progress: _progress,
              themeMode: _themeMode,
              soundEnabled: _soundEnabled,
              musicEnabled: _musicEnabled,
              onProgressChanged: _refreshProgress,
              onThemeChanged: _setThemeMode,
              onSoundChanged: _setSoundEnabled,
              onMusicChanged: _setMusicEnabled,
            ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5D8CFF),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0B1018)
          : const Color(0xFFF4F7FB),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF121A26) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
