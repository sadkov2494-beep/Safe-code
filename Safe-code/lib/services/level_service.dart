import '../data/levels.dart';
import '../models/level.dart';
import '../models/player_progress.dart';

class LevelService {
  const LevelService();

  List<Level> get levels => allLevels;

  Level levelById(int id) {
    return levels.firstWhere((level) => level.id == id);
  }

  bool isUnlocked(Level level, PlayerProgress progress) {
    if (level.id == levels.first.id) {
      return true;
    }
    return progress.isCompleted(level.id - 1);
  }

  Level? nextLevel(Level current) {
    final index = levels.indexWhere((level) => level.id == current.id);
    if (index == -1 || index == levels.length - 1) {
      return null;
    }
    return levels[index + 1];
  }
}
