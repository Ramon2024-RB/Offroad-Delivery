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

          ValueListenableBuilder<bool>(
            valueListenable: _game.routeChoiceNotifier,
            builder: (context, showRouteChoice, _) {
              if (!showRouteChoice) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.55,
                  ),
                  child: Center(
                    child: Container(
                      width: 520,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF172014),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ROUTENWAHL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Wie möchtest du die Lieferung fortsetzen?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _RouteButton(
                                  title: 'SICHERE ROUTE',
                                  description:
                                      'Normaler Weg\nBelohnung ×1,0',
                                  icon: Icons.route_rounded,
                                  onPressed: _game.selectSafeRoute,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _RouteButton(
                                  title: 'RISIKOROUTE',
                                  description:
                                      'Schwerer Weg\nBelohnung ×1,5',
                                  icon:
                                      Icons.warning_amber_rounded,
                                  onPressed: _game.selectRiskRoute,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

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

class _RouteButton extends StatelessWidget {
  const _RouteButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
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