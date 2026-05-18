class LevelProgress {
  const LevelProgress({
    required this.levelId,
    required this.bestStars,
    required this.completedAt,
  });

  final int levelId;
  final int bestStars;
  final DateTime completedAt;

  LevelProgress copyWith({int? bestStars, DateTime? completedAt}) {
    return LevelProgress(
      levelId: levelId,
      bestStars: bestStars ?? this.bestStars,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'levelId': levelId,
      'bestStars': bestStars,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  static LevelProgress fromJson(Map<String, Object?> json) {
    return LevelProgress(
      levelId: json['levelId']! as int,
      bestStars: json['bestStars']! as int,
      completedAt: DateTime.parse(json['completedAt']! as String),
    );
  }
}

class PlayerProgress {
  const PlayerProgress({
    required this.levels,
    this.lastDailyBonusDate,
    this.lastDailySafeDate,
    this.dailyStreak = 0,
    this.bestDailyStreak = 0,
  });

  static const dailySafeIdBase = 80000000;

  factory PlayerProgress.empty() {
    return const PlayerProgress(levels: {});
  }

  final Map<int, LevelProgress> levels;
  final DateTime? lastDailyBonusDate;
  final DateTime? lastDailySafeDate;
  final int dailyStreak;
  final int bestDailyStreak;

  int get completedCount {
    return levels.keys.where((levelId) => levelId < dailySafeIdBase).length;
  }

  int bestStarsFor(int levelId) => levels[levelId]?.bestStars ?? 0;

  bool isCompleted(int levelId) => levels.containsKey(levelId);

  int get totalStars {
    return levels.values.fold<int>(0, (sum, level) => sum + level.bestStars);
  }

  int get openedDailySafes {
    return levels.keys.where((levelId) => levelId >= dailySafeIdBase).length;
  }

  PlayerProgress copyWith({
    Map<int, LevelProgress>? levels,
    DateTime? lastDailyBonusDate,
    DateTime? lastDailySafeDate,
    int? dailyStreak,
    int? bestDailyStreak,
  }) {
    return PlayerProgress(
      levels: levels ?? this.levels,
      lastDailyBonusDate: lastDailyBonusDate ?? this.lastDailyBonusDate,
      lastDailySafeDate: lastDailySafeDate ?? this.lastDailySafeDate,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      bestDailyStreak: bestDailyStreak ?? this.bestDailyStreak,
    );
  }
}
