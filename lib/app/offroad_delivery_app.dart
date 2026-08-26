import 'package:flutter/material.dart';

import '../screens/main_menu_page.dart';

class OffroadDeliveryApp extends StatelessWidget {
  const OffroadDeliveryApp({super.key});

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
      home: const MainMenuPage(),
    );
  }
}