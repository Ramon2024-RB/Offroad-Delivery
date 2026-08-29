import 'package:flutter/material.dart';

import '../progress/player_progress_controller.dart';
import '../screens/main_menu_page.dart';

class OffroadDeliveryApp extends StatefulWidget {
  const OffroadDeliveryApp({super.key});

  @override
  State<OffroadDeliveryApp> createState() => _OffroadDeliveryAppState();
}

class _OffroadDeliveryAppState extends State<OffroadDeliveryApp> {
  late final PlayerProgressController _progressController;

  @override
  void initState() {
    super.initState();

    _progressController = PlayerProgressController();

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _progressController.load();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offroad Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF405D27),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainMenuPage(progressController: _progressController),
    );
  }
}
