import 'dart:ui';

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'agroconnect_onboarding.dart';
//import 'farmer_login_screen.dart';
import 'agroconnectlogin.dart';

void main() {
  runApp(const AgroConnectApp());
}

/// Root app widget.
/// Theme colors are pulled straight from the AgroConnect AI brand:
/// deep green (#1F5B3A-ish) for primary, soft sky gradient for backgrounds.
class AgroConnectApp extends StatelessWidget {
  const AgroConnectApp({super.key});

  static const Color brandGreen = Color(0xFF1F5B3A);
  static const Color brandGreenLight = Color(0xFF3D7A55);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroConnect AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
          secondary: brandGreenLight,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const FarmerLoginScreen(),
    );
  }
}