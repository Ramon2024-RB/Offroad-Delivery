import 'package:shared_preferences/shared_preferences.dart';

import 'mission_record.dart';
import 'player_progress.dart';

class PlayerProgressStorage {
  static const String _moneyKey = 'player_money';
  static const String _xpKey = 'player_xp';
  static const String _levelKey = 'player_level';

  static const String _missionBestTimePrefix = 'mission_best_time_';

  static const String _missionBestStarsPrefix = 'mission_best_stars_';

  Future<PlayerProgress> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final int money = preferences.getInt(_moneyKey) ?? 0;

    final int xp = preferences.getInt(_xpKey) ?? 0;

    final int level = preferences.getInt(_levelKey) ?? 1;

    return PlayerProgress(money: money, xp: xp, level: level);
  }

  Future<void> save(PlayerProgress progress) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setInt(_moneyKey, progress.money);

    await preferences.setInt(_xpKey, progress.xp);

    await preferences.setInt(_levelKey, progress.level);
  }

  Future<MissionRecord?> loadMissionRecord(String missionId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final String timeKey = '$_missionBestTimePrefix$missionId';

    final String starsKey = '$_missionBestStarsPrefix$missionId';

    final double? bestTimeSeconds = preferences.getDouble(timeKey);

    final int? bestStars = preferences.getInt(starsKey);

    if (bestTimeSeconds == null || bestStars == null) {
      return null;
    }

    return MissionRecord(
      missionId: missionId,
      bestTimeSeconds: bestTimeSeconds,
      bestStars: bestStars,
    );
  }

  Future<void> saveMissionRecord(MissionRecord record) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final String timeKey = '$_missionBestTimePrefix${record.missionId}';

    final String starsKey = '$_missionBestStarsPrefix${record.missionId}';

    await preferences.setDouble(timeKey, record.bestTimeSeconds);

    await preferences.setInt(starsKey, record.bestStars);
  }

  Future<void> reset() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove(_moneyKey);
    await preferences.remove(_xpKey);
    await preferences.remove(_levelKey);

    final Set<String> keys = preferences.getKeys();

    for (final String key in keys) {
      if (key.startsWith(_missionBestTimePrefix) ||
          key.startsWith(_missionBestStarsPrefix)) {
        await preferences.remove(key);
      }
    }
  }
}
