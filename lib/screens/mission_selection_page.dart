import 'package:flutter/material.dart';

import '../missions/delivery_mission.dart';
import '../missions/mission_catalog.dart';
import '../progress/mission_record.dart';
import '../progress/player_progress_controller.dart';
import 'game_page.dart';

class MissionSelectionPage extends StatefulWidget {
  const MissionSelectionPage({required this.progressController, super.key});

  final PlayerProgressController progressController;

  @override
  State<MissionSelectionPage> createState() => _MissionSelectionPageState();
}

class _MissionSelectionPageState extends State<MissionSelectionPage> {
  // NUR FÜR DIE ENTWICKLUNG:
  // true = alle Missionen können getestet werden.
  // false = normale Level-Sperren gelten wieder.
  static const bool _developmentUnlockAllMissions = true;

  final Map<String, MissionRecord?> _missionRecords =
      <String, MissionRecord?>{};

  bool _recordsLoaded = false;

  PlayerProgressController get progressController => widget.progressController;

  @override
  void initState() {
    super.initState();

    progressController.addListener(_onProgressChanged);

    _loadMissionRecords();
  }

  @override
  void dispose() {
    progressController.removeListener(_onProgressChanged);

    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      for (final DeliveryMission mission in MissionCatalog.missions) {
        final MissionRecord? cachedRecord = progressController
            .cachedMissionRecord(mission.id);

        if (cachedRecord != null) {
          _missionRecords[mission.id] = cachedRecord;
        }
      }
    });
  }

  Future<void> _loadMissionRecords() async {
    final Map<String, MissionRecord?> loadedRecords =
        <String, MissionRecord?>{};

    for (final DeliveryMission mission in MissionCatalog.missions) {
      final MissionRecord? record = await progressController.loadMissionRecord(
        mission.id,
      );

      loadedRecords[mission.id] = record;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _missionRecords
        ..clear()
        ..addAll(loadedRecords);

      _recordsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10170D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            if (_developmentUnlockAllMissions) _buildDevelopmentNotice(),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                itemCount: MissionCatalog.missions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DeliveryMission mission =
                      MissionCatalog.missions[index];

                  return _MissionCard(
                    mission: mission,
                    playerLevel: progressController.level,
                    developmentUnlocked: _developmentUnlockAllMissions,
                    record: _missionRecords[mission.id],
                    recordsLoaded: _recordsLoaded,
                    onStart: () {
                      _startMission(context, mission);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 10),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUFTRÄGE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Wähle deine nächste Lieferung',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ],
            ),
          ),

          _HeaderValue(
            icon: Icons.shield_rounded,
            text: 'LVL ${progressController.level}',
          ),

          const SizedBox(width: 8),

          _HeaderValue(
            icon: Icons.monetization_on_rounded,
            text: '${progressController.money}',
          ),

          const SizedBox(width: 8),

          _HeaderValue(
            icon: Icons.star_rounded,
            text: '${progressController.xp} XP',
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 2, 24, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2513),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x55FFD866)),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_rounded, size: 18, color: Color(0xFFFFD866)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'ENTWICKLUNGSMODUS – alle Aufträge sind zum Testen verfügbar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD866),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startMission(
    BuildContext context,
    DeliveryMission mission,
  ) async {
    final bool normallyUnlocked = mission.isUnlockedForLevel(
      progressController.level,
    );

    if (!normallyUnlocked && !_developmentUnlockAllMissions) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GamePage(progressController: progressController, mission: mission),
      ),
    );

    if (!mounted) {
      return;
    }

    final MissionRecord? record = progressController.cachedMissionRecord(
      mission.id,
    );

    setState(() {
      _missionRecords[mission.id] = record;
    });
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.playerLevel,
    required this.developmentUnlocked,
    required this.record,
    required this.recordsLoaded,
    required this.onStart,
  });

  final DeliveryMission mission;
  final int playerLevel;
  final bool developmentUnlocked;
  final MissionRecord? record;
  final bool recordsLoaded;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bool normallyUnlocked = mission.isUnlockedForLevel(playerLevel);

    final bool playable = normallyUnlocked || developmentUnlocked;

    final bool developmentOnly = !normallyUnlocked && developmentUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: playable ? const Color(0xFF1A2616) : const Color(0xFF171917),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: developmentOnly
              ? const Color(0x55FFD866)
              : playable
              ? Colors.white12
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: playable ? const Color(0xFF2B3D22) : Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              playable ? _cargoIcon(mission.cargoType) : Icons.lock_rounded,
              size: 29,
              color: playable ? const Color(0xFFFFD866) : Colors.white38,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: playable ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),

                    if (developmentOnly) ...[
                      const SizedBox(width: 8),
                      const _DevelopmentBadge(),
                    ],

                    const SizedBox(width: 8),

                    _DifficultyBadge(difficulty: mission.difficulty),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  mission.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: playable ? Colors.white60 : Colors.white30,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    _RewardValue(
                      icon: Icons.monetization_on_rounded,
                      text: '${mission.moneyReward}',
                    ),

                    const SizedBox(width: 14),

                    _RewardValue(
                      icon: Icons.star_rounded,
                      text: '${mission.xpReward} XP',
                    ),

                    const SizedBox(width: 14),

                    Icon(
                      _destinationIcon(mission.destinationType),
                      size: 16,
                      color: Colors.white54,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      _destinationText(mission.destinationType),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                _MissionRecordDisplay(
                  record: record,
                  recordsLoaded: recordsLoaded,

                  // WICHTIG:
                  // Nicht mehr nur die
                  // Zeitsterne verwenden.
                  // Dadurch können Missionen
                  // jetzt z.B. 5 Sterne haben.
                  maxStars: mission.maxStars,
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          SizedBox(
            width: 125,
            height: 44,
            child: FilledButton(
              onPressed: playable ? onStart : null,
              child: Text(
                playable ? 'ANNEHMEN' : 'LEVEL ${mission.requiredLevel}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _cargoIcon(CargoType cargoType) {
    switch (cargoType) {
      case CargoType.parcel:
        return Icons.inventory_2_rounded;

      case CargoType.food:
        return Icons.restaurant_rounded;

      case CargoType.buildingMaterials:
        return Icons.construction_rounded;

      case CargoType.vehicleParts:
        return Icons.build_rounded;
    }
  }

  IconData _destinationIcon(DestinationType destinationType) {
    switch (destinationType) {
      case DestinationType.house:
        return Icons.home_rounded;

      case DestinationType.mountainHut:
        return Icons.cabin_rounded;

      case DestinationType.constructionSite:
        return Icons.construction_rounded;

      case DestinationType.workshop:
        return Icons.garage_rounded;
    }
  }

  String _destinationText(DestinationType destinationType) {
    switch (destinationType) {
      case DestinationType.house:
        return 'Wohnhaus';

      case DestinationType.mountainHut:
        return 'Berghütte';

      case DestinationType.constructionSite:
        return 'Baustelle';

      case DestinationType.workshop:
        return 'Werkstatt';
    }
  }
}

class _MissionRecordDisplay extends StatelessWidget {
  const _MissionRecordDisplay({
    required this.record,
    required this.recordsLoaded,
    required this.maxStars,
  });

  final MissionRecord? record;
  final bool recordsLoaded;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    if (!recordsLoaded) {
      return const Row(
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          ),
          SizedBox(width: 7),
          Text(
            'Bestleistung wird geladen ...',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      );
    }

    if (record == null) {
      return const Row(
        children: [
          Icon(Icons.flag_outlined, size: 15, color: Colors.white30),
          SizedBox(width: 5),
          Text(
            'NOCH NICHT ABGESCHLOSSEN',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          size: 16,
          color: Color(0xFFF2C94C),
        ),

        const SizedBox(width: 5),

        Text(
          'BESTZEIT ${_formatTime(record!.bestTimeSeconds)}',
          style: const TextStyle(
            color: Color(0xFFF2C94C),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: Colors.white38,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(maxStars, (int index) {
            final bool active = index < record!.bestStars;

            return Icon(
              active ? Icons.star_rounded : Icons.star_border_rounded,
              size: 15,
              color: active ? const Color(0xFFFFD866) : Colors.white24,
            );
          }),
        ),
      ],
    );
  }

  String _formatTime(double seconds) {
    final int totalSeconds = seconds.floor();

    final int minutes = totalSeconds ~/ 60;

    final int remainingSeconds = totalSeconds % 60;

    return '$minutes:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _DevelopmentBadge extends StatelessWidget {
  const _DevelopmentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x22FFD866),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x55FFD866)),
      ),
      child: const Text(
        'TEST',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFD866),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final MissionDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  String get _text {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return 'EINFACH';

      case MissionDifficulty.medium:
        return 'MITTEL';

      case MissionDifficulty.hard:
        return 'SCHWER';
    }
  }
}

class _RewardValue extends StatelessWidget {
  const _RewardValue({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFFD866)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _HeaderValue extends StatelessWidget {
  const _HeaderValue({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD866)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
