import 'package:flutter/material.dart';

import '../missions/delivery_mission.dart';
import '../missions/mission_catalog.dart';
import '../progress/player_progress_controller.dart';
import 'game_page.dart';

class MissionSelectionPage extends StatelessWidget {
  const MissionSelectionPage({required this.progressController, super.key});

  final PlayerProgressController progressController;

  // NUR FÜR DIE ENTWICKLUNG:
  // true = alle Missionen können getestet werden.
  // false = normale Level-Sperren gelten wieder.
  static const bool _developmentUnlockAllMissions = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressController,
      builder: (context, _) {
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
      },
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

  void _startMission(BuildContext context, DeliveryMission mission) {
    final bool normallyUnlocked = mission.isUnlockedForLevel(
      progressController.level,
    );

    if (!normallyUnlocked && !_developmentUnlockAllMissions) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GamePage(progressController: progressController, mission: mission),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.playerLevel,
    required this.developmentUnlocked,
    required this.onStart,
  });

  final DeliveryMission mission;
  final int playerLevel;
  final bool developmentUnlocked;
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
