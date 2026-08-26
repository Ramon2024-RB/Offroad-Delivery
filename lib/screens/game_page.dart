import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/offroad_delivery_game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final OffroadDeliveryGame _game;

  @override
  void initState() {
    super.initState();

    _game = OffroadDeliveryGame();
  }

  void _startGas() {
    _game.setThrottle(1);
  }

  void _startBrake() {
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

          // Zurück-Button
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

          // Festes Missions-HUD
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 90,
                  right: 90,
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: _game.missionNotifier,
                  builder: (context, missionText, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Text(
                        missionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Bremse / Rückwärts
          Positioned(
            left: 30,
            bottom: 25,
            child: _ControlButton(
              icon: Icons.keyboard_double_arrow_left_rounded,
              label: 'BREMSE',
              onPressed: _startBrake,
              onReleased: _releasePedal,
            ),
          ),

          // Gas
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
        width: 110,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white38,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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