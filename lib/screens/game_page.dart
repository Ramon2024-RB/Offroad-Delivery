import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/physics_test_game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() =>
      _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final PhysicsTestGame _game;

  bool _showDeliveryCompleted = false;

  int _moneyReward = 0;
  int _xpReward = 0;

  @override
  void initState() {
    super.initState();

    _game = PhysicsTestGame(
      onDeliveryCompleted: (
        int moneyReward,
        int xpReward,
      ) {
        if (!mounted) {
          return;
        }

        setState(() {
          _moneyReward = moneyReward;
          _xpReward = xpReward;
          _showDeliveryCompleted = true;
        });
      },
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),

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
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------
          // TEST-VERSION
          // ------------------------------------------

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 90,
                  right: 90,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.65,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: const Text(
                    'PHYSIK-TEST • v0.2.2',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------
          // LIEFERUNG ABGESCHLOSSEN HUD
          // ------------------------------------------

          if (_showDeliveryCompleted)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 72,
                    left: 20,
                    right: 20,
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 430,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xEE1D2A20,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(
                          0xFFF2C94C,
                        ),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 12,
                          offset: Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Text(
                          'LIEFERUNG ABGESCHLOSSEN!',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          '+$_moneyReward Geld   •   +$_xpReward XP',
                          textAlign:
                              TextAlign.center,
                          style: const TextStyle(
                            color: Color(
                              0xFFFFD866,
                            ),
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ------------------------------------------
          // RÜCKWÄRTS
          // ------------------------------------------

          Positioned(
            left: 30,
            bottom: 25,
            child: _ControlButton(
              icon: Icons
                  .keyboard_double_arrow_left_rounded,
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
              icon: Icons
                  .keyboard_double_arrow_right_rounded,
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
          color: Colors.black.withValues(
            alpha: 0.55,
          ),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white38,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(
              height: 2,
            ),
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