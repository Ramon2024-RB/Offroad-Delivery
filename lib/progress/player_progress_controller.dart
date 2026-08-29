import 'package:flutter/foundation.dart';

import 'player_progress.dart';
import 'player_progress_storage.dart';

class PlayerProgressController extends ChangeNotifier {
  PlayerProgressController({PlayerProgressStorage? storage})
    : _storage = storage ?? PlayerProgressStorage();

  final PlayerProgressStorage _storage;

  PlayerProgress _progress = PlayerProgress.initial();

  bool _isLoaded = false;

  PlayerProgress get progress => _progress;

  int get money => _progress.money;

  int get xp => _progress.xp;

  int get level => _progress.level;

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _progress = await _storage.load();
    _isLoaded = true;

    notifyListeners();
  }

  Future<void> addRewards({
    required int moneyReward,
    required int xpReward,
  }) async {
    _progress = _progress.addRewards(
      moneyReward: moneyReward,
      xpReward: xpReward,
    );

    notifyListeners();

    await _storage.save(_progress);
  }

  Future<void> reset() async {
    _progress = PlayerProgress.initial();

    notifyListeners();

    await _storage.reset();
  }
}
