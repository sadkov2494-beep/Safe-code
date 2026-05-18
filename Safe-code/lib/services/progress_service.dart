import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notebook_entry.dart';
import '../models/player_progress.dart';

class ProgressService {
  const ProgressService();

  static const _levelsKey = 'safe_code.level_progress';
  static const _dailyBonusKey = 'safe_code.last_daily_bonus';
  static const _themeKey = 'safe_code.theme_mode';
  static const _onboardingKey = 'safe_code.onboarding_completed';
  static const _notebookPrefix = 'safe_code.notebook.';

  Future<PlayerProgress> loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    final rawLevels = preferences.getString(_levelsKey);
    final rawDailyBonus = preferences.getString(_dailyBonusKey);
    final levels = <int, LevelProgress>{};

    if (rawLevels != null && rawLevels.isNotEmpty) {
      final decoded = jsonDecode(rawLevels) as List<dynamic>;
      for (final item in decoded) {
        final progress = LevelProgress.fromJson(
          Map<String, Object?>.from(item as Map<dynamic, dynamic>),
        );
        levels[progress.levelId] = progress;
      }
    }

    return PlayerProgress(
      levels: levels,
      lastDailyBonusDate: rawDailyBonus == null
          ? null
          : DateTime.tryParse(rawDailyBonus),
    );
  }

  Future<void> saveLevelResult({
    required int levelId,
    required int stars,
  }) async {
    final progress = await loadProgress();
    final current = progress.levels[levelId];
    if (current != null && current.bestStars >= stars) {
      return;
    }

    final updated = Map<int, LevelProgress>.from(progress.levels)
      ..[levelId] = LevelProgress(
        levelId: levelId,
        bestStars: stars,
        completedAt: DateTime.now(),
      );

    await _saveLevels(updated);
  }

  Future<bool> claimDailyBonus() async {
    final preferences = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final rawDailyBonus = preferences.getString(_dailyBonusKey);
    final lastClaim = rawDailyBonus == null
        ? null
        : DateTime.tryParse(rawDailyBonus);

    if (lastClaim != null && _dateOnly(lastClaim) == today) {
      return false;
    }

    await preferences.setString(_dailyBonusKey, today.toIso8601String());
    return true;
  }

  Future<String> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_themeKey) ?? 'dark';
  }

  Future<void> saveThemeMode(String mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, mode);
  }

  Future<bool> loadOnboardingCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveOnboardingCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, true);
  }

  Future<NotebookEntry> loadNotebook(int levelId) async {
    final preferences = await SharedPreferences.getInstance();
    final rawNotebook = preferences.getString('$_notebookPrefix$levelId');
    if (rawNotebook == null || rawNotebook.isEmpty) {
      return NotebookEntry.empty();
    }
    return NotebookEntry.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rawNotebook) as Map<dynamic, dynamic>,
      ),
    );
  }

  Future<void> saveNotebook(int levelId, NotebookEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_notebookPrefix$levelId',
      jsonEncode(entry.toJson()),
    );
  }

  Future<void> _saveLevels(Map<int, LevelProgress> levels) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      levels.values.map((level) => level.toJson()).toList(),
    );
    await preferences.setString(_levelsKey, encoded);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
