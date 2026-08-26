import 'package:flutter/material.dart';

import 'game_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF182312),
              Color(0xFF090D07),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLandscape =
                  constraints.maxWidth > constraints.maxHeight;

              if (isLandscape) {
                return _buildLandscapeMenu(context);
              }

              return _buildPortraitMenu(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTitleArea(
              iconSize: 64,
              titleSize: 36,
              subtitleSize: 21,
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitMenu(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 30,
        ),
        child: Column(
          children: [
            _buildTitleArea(
              iconSize: 72,
              titleSize: 38,
              subtitleSize: 22,
            ),
            const SizedBox(height: 35),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleArea({
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_shipping_rounded,
          size: iconSize,
          color: const Color(0xFFD8E9C5),
        ),
        const SizedBox(height: 12),
        Text(
          'OFFROAD',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ),
        Text(
          'DELIVERY',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
            color: const Color(0xFFA8C98A),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Deliver. Survive. Upgrade.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GamePage(),
                ),
              );
            },
            icon: const Icon(
              Icons.play_arrow_rounded,
            ),
            label: const Text(
              'SPIELEN',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(
              Icons.garage_rounded,
            ),
            label: const Text('GARAGE'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(
              Icons.settings_rounded,
            ),
            label: const Text('EINSTELLUNGEN'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Development Build • v0.1.3',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}