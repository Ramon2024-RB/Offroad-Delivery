import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress.dart';

class PlayerProgressStorage {
  static const String _moneyKey = 'player_money';
  static const String _xpKey = 'player_xp';
  static const String _levelKey = 'player_level';

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

  Future<void> reset() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove(_moneyKey);
    await preferences.remove(_xpKey);
    await preferences.remove(_levelKey);
  }
}
