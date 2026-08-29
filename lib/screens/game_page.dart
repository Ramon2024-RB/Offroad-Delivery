import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/physics_test_game.dart';
import '../progress/player_progress_controller.dart';

class GamePage extends StatefulWidget {
  const GamePage({required this.progressController, super.key});

  final PlayerProgressController progressController;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final PhysicsTestGame _game;

  String _missionText = 'Fahre zur Abholstation';

  IconData _missionIcon = Icons.inventory_2_rounded;

  bool _showDeliveryCompleted = false;

  int _moneyReward = 0;
  int _xpReward = 0;

  @override
  void initState() {
    super.initState();

    widget.progressController.addListener(_onProgressChanged);

    _game = PhysicsTestGame(
      onCargoPickedUp: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _missionText = 'Paket geladen – fahre zum Kunden';

          _missionIcon = Icons.local_shipping_rounded;
        });
      },
      onDeliveryCompleted: (int moneyReward, int xpReward) {
        _handleDeliveryCompleted(moneyReward, xpReward);
      },
    );
  }

  @override
  void dispose() {
    widget.progressController.removeListener(_onProgressChanged);

    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _handleDeliveryCompleted(int moneyReward, int xpReward) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _moneyReward = moneyReward;
      _xpReward = xpReward;

      _missionText = 'Lieferung abgeschlossen';

      _missionIcon = Icons.check_circle_rounded;

      _showDeliveryCompleted = true;
    });

    await widget.progressController.addRewards(
      moneyReward: moneyReward,
      xpReward: xpReward,
    );
  }

  void _startGas() {
    _game.setThrottle(1);
  }

  void _startReverse() {
    _game.setThrottle(-1);
  }

  void _releasePedal() {
    _game.setThrottle(0);
  }

  @override
  Widget build(BuildContext context) {
    final int money = widget.progressController.money;

    final int xp = widget.progressController.xp;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),

          // ------------------------------------------
          // ZURÜCK-BUTTON
          // ------------------------------------------
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
          // GELD UND XP
          // ------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 190, right: 190),
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
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
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
          // LIEFERUNG ABGESCHLOSSEN
          // ------------------------------------------
          if (_showDeliveryCompleted)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 78, left: 20, right: 20),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 430),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEE1D2A20),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF2C94C),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF7DDB83),
                              size: 25,
                            ),
                            SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                'LIEFERUNG ABGESCHLOSSEN!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '+$_moneyReward Geld   •   +$_xpReward XP',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFD866),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // RÜCKWÄRTS / BREMSE
          // ------------------------------------------
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

          // ------------------------------------------
          // GAS
          // ------------------------------------------
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
}

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
