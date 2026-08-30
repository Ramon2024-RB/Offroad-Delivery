import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/physics_test_game.dart';
import '../missions/delivery_mission.dart';
import '../progress/mission_record.dart';
import '../progress/player_progress_controller.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    required this.progressController,
    required this.mission,
    super.key,
  });

  final PlayerProgressController progressController;
  final DeliveryMission mission;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final PhysicsTestGame _game;

  final Random _random = Random();

  String _missionText = 'Fahre zur Abholstation';
  IconData _missionIcon = Icons.inventory_2_rounded;

  bool _showPickupOverlay = false;
  bool _showDeliveryCompleted = false;

  bool _pickupChallengeRunning = false;
  bool _pickupChallengeSolved = false;

  List<int> _packageNumbers = <int>[];
  int _targetPackageNumber = 0;

  Timer? _challengeTimer;
  DateTime? _challengeStartedAt;
  double _challengeSeconds = 0;

  int _pickupBonusMoney = 0;
  int _pickupBonusXp = 0;
  int _pickupStars = 0;

  int _moneyReward = 0;
  int _xpReward = 0;

  // ------------------------------------------
  // MISSIONSREKORD
  // ------------------------------------------

  bool _newBestTime = false;
  bool _newBestStars = false;

  double? _savedBestTime;
  int? _savedBestStars;

  // ------------------------------------------
  // MISSIONSZEIT
  // ------------------------------------------

  Timer? _missionTimer;

  bool _missionTimerRunning = false;

  DateTime? _missionSegmentStartedAt;

  double _missionAccumulatedSeconds = 0;
  double _missionSeconds = 0;

  int _missionTimeStars = 0;

  @override
  void initState() {
    super.initState();

    widget.progressController.addListener(_onProgressChanged);

    _game = PhysicsTestGame(
      mission: widget.mission,

      // ------------------------------------------
      // ABHOLSTATION ERREICHT
      // ------------------------------------------
      onPickupStationReached: () {
        if (!mounted) {
          return;
        }

        _pauseMissionTimer();

        setState(() {
          _showPickupOverlay = true;
          _missionText = 'Abholstation erreicht';
          _missionIcon = Icons.inventory_2_rounded;
        });
      },

      // ------------------------------------------
      // LADUNG WURDE EINGELADEN
      // ------------------------------------------
      onCargoPickedUp: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _showPickupOverlay = false;
          _pickupChallengeRunning = false;
          _pickupChallengeSolved = false;

          _missionText =
              '${_cargoName(widget.mission.cargoType)} geladen – '
              'fahre zum ${_destinationName(widget.mission.destinationType)}';

          _missionIcon = Icons.local_shipping_rounded;
        });
      },

      // ------------------------------------------
      // LIEFERUNG ABGESCHLOSSEN
      // ------------------------------------------
      onDeliveryCompleted: (int moneyReward, int xpReward) {
        _handleDeliveryCompleted(moneyReward, xpReward);
      },
    );
  }

  @override
  void dispose() {
    _challengeTimer?.cancel();
    _missionTimer?.cancel();

    widget.progressController.removeListener(_onProgressChanged);

    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ------------------------------------------
  // MISSIONSZEIT STARTEN / FORTSETZEN
  // ------------------------------------------

  void _startOrResumeMissionTimer() {
    if (_showDeliveryCompleted || _showPickupOverlay || _missionTimerRunning) {
      return;
    }

    _missionTimerRunning = true;
    _missionSegmentStartedAt = DateTime.now();

    _missionTimer?.cancel();

    _missionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted ||
          !_missionTimerRunning ||
          _missionSegmentStartedAt == null) {
        return;
      }

      final double currentSegmentSeconds =
          DateTime.now().difference(_missionSegmentStartedAt!).inMilliseconds /
          1000;

      setState(() {
        _missionSeconds = _missionAccumulatedSeconds + currentSegmentSeconds;
      });
    });
  }

  // ------------------------------------------
  // MISSIONSZEIT PAUSIEREN
  // ------------------------------------------

  void _pauseMissionTimer() {
    if (!_missionTimerRunning) {
      return;
    }

    if (_missionSegmentStartedAt != null) {
      final double currentSegmentSeconds =
          DateTime.now().difference(_missionSegmentStartedAt!).inMilliseconds /
          1000;

      _missionAccumulatedSeconds += currentSegmentSeconds;
      _missionSeconds = _missionAccumulatedSeconds;
    }

    _missionTimerRunning = false;
    _missionSegmentStartedAt = null;

    _missionTimer?.cancel();
    _missionTimer = null;

    if (mounted) {
      setState(() {});
    }
  }

  // ------------------------------------------
  // MISSIONSZEIT ENDGÜLTIG STOPPEN
  // ------------------------------------------

  double _stopMissionTimer() {
    if (_missionTimerRunning && _missionSegmentStartedAt != null) {
      final double currentSegmentSeconds =
          DateTime.now().difference(_missionSegmentStartedAt!).inMilliseconds /
          1000;

      _missionAccumulatedSeconds += currentSegmentSeconds;
    }

    _missionTimerRunning = false;
    _missionSegmentStartedAt = null;

    _missionTimer?.cancel();
    _missionTimer = null;

    _missionSeconds = _missionAccumulatedSeconds;

    return _missionSeconds;
  }

  // ------------------------------------------
  // MISSIONSZEIT AUSWERTEN
  // ------------------------------------------

  int _calculateMissionTimeStars(double seconds) {
    return widget.mission.evaluateMissionTime(seconds);
  }

  String _formatMissionTime(double seconds) {
    final int totalSeconds = seconds.floor();

    final int minutes = totalSeconds ~/ 60;
    final int remainingSeconds = totalSeconds % 60;

    final String secondsText = remainingSeconds.toString().padLeft(2, '0');

    return '$minutes:$secondsText';
  }

  // ------------------------------------------
  // LIEFERUNG ABSCHLIESSEN
  // ------------------------------------------

  Future<void> _handleDeliveryCompleted(int moneyReward, int xpReward) async {
    if (!mounted || _showDeliveryCompleted) {
      return;
    }

    _game.setThrottle(0);

    final double finalMissionTime = _stopMissionTimer();

    final int timeStars = _calculateMissionTimeStars(finalMissionTime);

    final int totalMoneyReward = moneyReward + _pickupBonusMoney;

    final int totalXpReward = xpReward + _pickupBonusXp;

    // ------------------------------------------
    // BISHERIGEN REKORD LADEN
    // ------------------------------------------

    final MissionRecord? previousRecord = await widget.progressController
        .loadMissionRecord(widget.mission.id);

    if (!mounted) {
      return;
    }

    final bool newBestTime =
        previousRecord == null ||
        finalMissionTime < previousRecord.bestTimeSeconds;

    final bool newBestStars =
        previousRecord == null || timeStars > previousRecord.bestStars;

    // ------------------------------------------
    // NEUES ERGEBNIS SPEICHERN
    // ------------------------------------------

    final MissionRecord savedRecord = await widget.progressController
        .recordMissionResult(
          missionId: widget.mission.id,
          timeSeconds: finalMissionTime,
          stars: timeStars,
        );

    if (!mounted) {
      return;
    }

    // ------------------------------------------
    // BELOHNUNG SPEICHERN
    // ------------------------------------------

    await widget.progressController.addRewards(
      moneyReward: totalMoneyReward,
      xpReward: totalXpReward,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _missionSeconds = finalMissionTime;
      _missionTimeStars = timeStars;

      _moneyReward = totalMoneyReward;
      _xpReward = totalXpReward;

      _savedBestTime = savedRecord.bestTimeSeconds;

      _savedBestStars = savedRecord.bestStars;

      _newBestTime = newBestTime;
      _newBestStars = newBestStars;

      _missionText = 'Lieferung abgeschlossen';
      _missionIcon = Icons.check_circle_rounded;

      _showDeliveryCompleted = true;
    });
  }

  // ------------------------------------------
  // NAVIGATION NACH MISSIONSENDE
  // ------------------------------------------

  void _goToMissionSelection() {
    Navigator.of(context).pop();
  }

  void _goToMainMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ------------------------------------------
  // SCHNELL BELADEN
  // ------------------------------------------

  void _quickLoadCargo() {
    _challengeTimer?.cancel();

    _pickupBonusMoney = 0;
    _pickupBonusXp = 0;
    _pickupStars = 0;

    _game.completePickup();
  }

  // ------------------------------------------
  // PAKET-CHALLENGE STARTEN
  // ------------------------------------------

  void _startPackageChallenge() {
    if (_pickupChallengeRunning) {
      return;
    }

    final Set<int> generatedNumbers = <int>{};

    while (generatedNumbers.length < 6) {
      generatedNumbers.add(100 + _random.nextInt(900));
    }

    final List<int> numbers = generatedNumbers.toList()..shuffle(_random);

    final int target = numbers[_random.nextInt(numbers.length)];

    _challengeTimer?.cancel();

    setState(() {
      _packageNumbers = numbers;
      _targetPackageNumber = target;

      _pickupChallengeRunning = true;
      _pickupChallengeSolved = false;

      _challengeSeconds = 0;

      _pickupBonusMoney = 0;
      _pickupBonusXp = 0;
      _pickupStars = 0;
    });

    _challengeStartedAt = DateTime.now();

    _challengeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _challengeStartedAt == null) {
        return;
      }

      final double seconds =
          DateTime.now().difference(_challengeStartedAt!).inMilliseconds / 1000;

      setState(() {
        _challengeSeconds = seconds;
      });
    });
  }

  // ------------------------------------------
  // PAKET AUSWÄHLEN
  // ------------------------------------------

  Future<void> _selectPackage(int packageNumber) async {
    if (!_pickupChallengeRunning || _pickupChallengeSolved) {
      return;
    }

    if (packageNumber != _targetPackageNumber) {
      return;
    }

    _challengeTimer?.cancel();

    final double finalTime = _challengeStartedAt == null
        ? _challengeSeconds
        : DateTime.now().difference(_challengeStartedAt!).inMilliseconds / 1000;

    int stars;
    int bonusMoney;
    int bonusXp;

    if (finalTime <= 5.0) {
      stars = 3;
      bonusMoney = 50;
      bonusXp = 20;
    } else if (finalTime <= 10.0) {
      stars = 2;
      bonusMoney = 25;
      bonusXp = 10;
    } else {
      stars = 1;
      bonusMoney = 0;
      bonusXp = 0;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _challengeSeconds = finalTime;
      _pickupChallengeSolved = true;

      _pickupStars = stars;
      _pickupBonusMoney = bonusMoney;
      _pickupBonusXp = bonusXp;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1100));

    if (!mounted) {
      return;
    }

    _game.completePickup();
  }

  // ------------------------------------------
  // NAMEN
  // ------------------------------------------

  String _cargoName(CargoType cargoType) {
    switch (cargoType) {
      case CargoType.parcel:
        return 'Paket';

      case CargoType.food:
        return 'Vorräte';

      case CargoType.buildingMaterials:
        return 'Baumaterial';

      case CargoType.vehicleParts:
        return 'Ersatzteile';
    }
  }

  String _destinationName(DestinationType destinationType) {
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

  // ------------------------------------------
  // STEUERUNG
  // ------------------------------------------

  void _startGas() {
    if (_showPickupOverlay || _showDeliveryCompleted) {
      return;
    }

    _startOrResumeMissionTimer();
    _game.setThrottle(1);
  }

  void _startReverse() {
    if (_showPickupOverlay || _showDeliveryCompleted) {
      return;
    }

    _startOrResumeMissionTimer();
    _game.setThrottle(-1);
  }

  void _releasePedal() {
    _game.setThrottle(0);
  }

  // ------------------------------------------
  // BUILD
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    final int money = widget.progressController.money;

    final int xp = widget.progressController.xp;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),

          // ------------------------------------------
          // ZURÜCK
          // ------------------------------------------
          if (!_showDeliveryCompleted)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // GELD, XP UND ZEIT
          // ------------------------------------------
          if (!_showDeliveryCompleted)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HudValue(
                        icon: Icons.timer_outlined,
                        value: _formatMissionTime(_missionSeconds),
                      ),
                      const SizedBox(width: 8),
                      _HudValue(
                        icon: Icons.monetization_on_rounded,
                        value: '$money',
                      ),
                      const SizedBox(width: 8),
                      _HudValue(icon: Icons.star_rounded, value: '$xp XP'),
                    ],
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // MISSIONSZIEL
          // ------------------------------------------
          if (!_showDeliveryCompleted)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 190,
                    right: 260,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _missionIcon,
                          color: const Color(0xFFFFD866),
                          size: 22,
                        ),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            _missionText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // ABHOLSTATION
          // ------------------------------------------
          if (_showPickupOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: SafeArea(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: _pickupChallengeRunning ? 560 : 470,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xF21C2420),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF2B84B),
                          width: 2,
                        ),
                      ),
                      child: _pickupChallengeRunning
                          ? _buildPackageChallenge()
                          : _buildPickupMenu(),
                    ),
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // MISSIONSABSCHLUSS
          // ------------------------------------------
          if (_showDeliveryCompleted)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.68),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double availableWidth = constraints.maxWidth;

                          final double availableHeight = constraints.maxHeight;

                          final double cardWidth = min(
                            720,
                            availableWidth - 32,
                          ).toDouble();

                          final double cardHeight = min(
                            320,
                            availableHeight - 28,
                          ).toDouble();

                          return Center(
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xF21D2A20),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFF2C94C),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 20,
                                      offset: Offset(0, 7),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: _buildCompletionSummary(),
                                    ),
                                    const SizedBox(width: 18),
                                    Container(
                                      width: 1,
                                      height: double.infinity,
                                      color: Colors.white12,
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      flex: 5,
                                      child: _buildCompletionActions(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // STEUERUNG
          // ------------------------------------------
          if (!_showDeliveryCompleted)
            Positioned(
              left: 30,
              bottom: 25,
              child: _ControlButton(
                icon: Icons.keyboard_double_arrow_left_rounded,
                label: 'RÜCKWÄRTS',
                onPressed: _startReverse,
                onReleased: _releasePedal,
              ),
            ),

          if (!_showDeliveryCompleted)
            Positioned(
              right: 30,
              bottom: 25,
              child: _ControlButton(
                icon: Icons.keyboard_double_arrow_right_rounded,
                label: 'GAS',
                onPressed: _startGas,
                onReleased: _releasePedal,
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // ABSCHLUSS – LINKE SEITE
  // ------------------------------------------

  Widget _buildCompletionSummary() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFF2C94C),
          size: 28,
        ),
        const SizedBox(height: 2),
        const Text(
          'LIEFERUNG ABGESCHLOSSEN!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.mission.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),

        // ------------------------------------------
        // MISSIONSZEIT
        // ------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MISSIONSZEIT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _formatMissionTime(_missionSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              _buildMissionTimeStars(),

              if (_newBestTime || _newBestStars) ...[
                const SizedBox(height: 2),
                Text(
                  _newBestTime && _newBestStars
                      ? 'NEUER REKORD!'
                      : _newBestTime
                      ? 'NEUE BESTZEIT!'
                      : 'NEUE BESTWERTUNG!',
                  style: const TextStyle(
                    color: Color(0xFF7DDB83),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 6),

        // ------------------------------------------
        // BESTLEISTUNG
        // ------------------------------------------
        if (_savedBestTime != null && _savedBestStars != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.white54,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  'BESTE LEISTUNG: '
                  '${_formatMissionTime(_savedBestTime!)}'
                  '  •  $_savedBestStars/${widget.mission.timeRatingRule?.maxStars ?? 3} ⭐',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),

        // ------------------------------------------
        // BELOHNUNG
        // ------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GESAMTBELOHNUNG',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '+$_moneyReward Geld  •  +$_xpReward XP',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD866),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_pickupBonusMoney > 0 || _pickupBonusXp > 0) ...[
                const SizedBox(height: 1),
                Text(
                  'Abholbonus: '
                  '+$_pickupBonusMoney Geld / '
                  '+$_pickupBonusXp XP',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7DDB83),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionTimeStars() {
    final int maxStars = widget.mission.ratingRules
        .where(
          (MissionRatingRule rule) =>
              rule.category == MissionRatingCategory.deliveryTime,
        )
        .fold<int>(
          0,
          (int total, MissionRatingRule rule) => total + rule.maxStars,
        );

    final int visibleMaxStars = maxStars > 0 ? maxStars : 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(visibleMaxStars, (int index) {
        final bool active = index < _missionTimeStars;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            active ? Icons.star_rounded : Icons.star_border_rounded,
            color: active ? const Color(0xFFFFD866) : Colors.white30,
            size: 19,
          ),
        );
      }),
    );
  }

  // ------------------------------------------
  // ABSCHLUSS – RECHTE SEITE
  // ------------------------------------------

  Widget _buildCompletionActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_pickupStars > 0) ...[
          const Text(
            'ABHOL-CHALLENGE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(3, (int index) {
              final bool active = index < _pickupStars;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  active ? Icons.star_rounded : Icons.star_border_rounded,
                  color: active ? const Color(0xFFFFD866) : Colors.white30,
                  size: 26,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _goToMissionSelection,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF2B84B),
              foregroundColor: const Color(0xFF2C2517),
              minimumSize: const Size(0, 46),
            ),
            icon: const Icon(Icons.assignment_rounded),
            label: const Text(
              'NÄCHSTER AUFTRAG',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _goToMainMenu,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              minimumSize: const Size(0, 46),
            ),
            icon: const Icon(Icons.home_rounded),
            label: const Text(
              'HAUPTMENÜ',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------
  // ABHOLMENÜ
  // ------------------------------------------

  Widget _buildPickupMenu() {
    final bool packageChallengeAvailable =
        widget.mission.cargoType == CargoType.parcel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.inventory_2_rounded,
          color: Color(0xFFF2B84B),
          size: 42,
        ),
        const SizedBox(height: 10),
        const Text(
          'ABHOLSTATION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_cargoName(widget.mission.cargoType)} '
          'steht zur Abholung bereit.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 20),

        if (packageChallengeAvailable) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _startPackageChallenge,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF2B84B),
                foregroundColor: const Color(0xFF2C2517),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.stars_rounded),
              label: const Text(
                'BONUS-CHALLENGE STARTEN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Finde die richtige Sendung möglichst schnell.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _quickLoadCargo,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.local_shipping_rounded),
            label: const Text(
              'SCHNELL BELADEN',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),

        if (!packageChallengeAvailable) ...[
          const SizedBox(height: 10),
          const Text(
            'Eine eigene Bonus-Challenge für diese Ladung folgt später.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------
  // PAKET-CHALLENGE
  // ------------------------------------------

  Widget _buildPackageChallenge() {
    if (_pickupChallengeSolved) {
      return _buildChallengeResult();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_rounded, color: Color(0xFFF2B84B), size: 36),
        const SizedBox(height: 6),
        const Text(
          'FINDE DIE RICHTIGE SENDUNG',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'GESUCHT',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'SENDUNG #$_targetPackageNumber',
          style: const TextStyle(
            color: Color(0xFFFFD866),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${_challengeSeconds.toStringAsFixed(1)} s',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _packageNumbers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.25,
          ),
          itemBuilder: (context, index) {
            final int packageNumber = _packageNumbers[index];

            return Material(
              color: const Color(0xFFD9903D),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _selectPackage(packageNumber);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD080),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        color: Color(0xFF5C4520),
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '#$packageNumber',
                        style: const TextStyle(
                          color: Color(0xFF332617),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        const Text(
          'Falsche Sendung? Kein Problem – die Zeit läuft nur weiter.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  // ------------------------------------------
  // CHALLENGE-ERGEBNIS
  // ------------------------------------------

  Widget _buildChallengeResult() {
    String rating;

    if (_pickupStars == 3) {
      rating = 'PERFEKT!';
    } else if (_pickupStars == 2) {
      rating = 'GUT!';
    } else {
      rating = 'GESCHAFFT!';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF7DDB83),
          size: 44,
        ),
        const SizedBox(height: 8),
        Text(
          rating,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int index) {
            final bool active = index < _pickupStars;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                active ? Icons.star_rounded : Icons.star_border_rounded,
                color: active ? const Color(0xFFFFD866) : Colors.white38,
                size: 32,
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        Text(
          '${_challengeSeconds.toStringAsFixed(1)} Sekunden',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 8),

        if (_pickupBonusMoney > 0 || _pickupBonusXp > 0)
          Text(
            '+$_pickupBonusMoney Geld   •   '
            '+$_pickupBonusXp XP',
            style: const TextStyle(
              color: Color(0xFFFFD866),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          const Text(
            'Kein Bonus – normale Missionsbelohnung bleibt erhalten.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
      ],
    );
  }
}

// ----------------------------------------------------
// HUD
// ----------------------------------------------------

class _HudValue extends StatelessWidget {
  const _HudValue({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: const Color(0xFFFFD866)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// STEUERUNG
// ----------------------------------------------------

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.onReleased,
  });

  final IconData icon;
  final String label;

  final VoidCallback onPressed;
  final VoidCallback onReleased;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        onPressed();
      },
      onPointerUp: (_) {
        onReleased();
      },
      onPointerCancel: (_) {
        onReleased();
      },
      child: Container(
        width: 120,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
