import 'package:flutter/foundation.dart';

import 'mission_record.dart';
import 'player_progress.dart';
import 'player_progress_storage.dart';

class PlayerProgressController extends ChangeNotifier {
  PlayerProgressController({PlayerProgressStorage? storage})
    : _storage = storage ?? PlayerProgressStorage();

  final PlayerProgressStorage _storage;

  PlayerProgress _progress = PlayerProgress.initial();

  final Map<String, MissionRecord> _missionRecords = <String, MissionRecord>{};

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

  Future<MissionRecord?> loadMissionRecord(String missionId) async {
    final MissionRecord? cachedRecord = _missionRecords[missionId];

    if (cachedRecord != null) {
      return cachedRecord;
    }

    final MissionRecord? storedRecord = await _storage.loadMissionRecord(
      missionId,
    );

    if (storedRecord != null) {
      _missionRecords[missionId] = storedRecord;
    }

    return storedRecord;
  }

  MissionRecord? cachedMissionRecord(String missionId) {
    return _missionRecords[missionId];
  }

  Future<MissionRecord> recordMissionResult({
    required String missionId,
    required double timeSeconds,
    required int stars,
  }) async {
    MissionRecord? currentRecord = await loadMissionRecord(missionId);

    if (currentRecord == null) {
      final MissionRecord newRecord = MissionRecord(
        missionId: missionId,
        bestTimeSeconds: timeSeconds,
        bestStars: stars,
      );

      _missionRecords[missionId] = newRecord;

      await _storage.saveMissionRecord(newRecord);

      notifyListeners();

      return newRecord;
    }

    double bestTimeSeconds = currentRecord.bestTimeSeconds;

    int bestStars = currentRecord.bestStars;

    bool improved = false;

    if (timeSeconds < bestTimeSeconds) {
      bestTimeSeconds = timeSeconds;
      improved = true;
    }

    if (stars > bestStars) {
      bestStars = stars;
      improved = true;
    }

    if (!improved) {
      return currentRecord;
    }

    final MissionRecord updatedRecord = MissionRecord(
      missionId: missionId,
      bestTimeSeconds: bestTimeSeconds,
      bestStars: bestStars,
    );

    _missionRecords[missionId] = updatedRecord;

    await _storage.saveMissionRecord(updatedRecord);

    notifyListeners();

    return updatedRecord;
  }

  Future<void> reset() async {
    _progress = PlayerProgress.initial();

    _missionRecords.clear();

    notifyListeners();

    await _storage.reset();
  }
}
