import \'package:flutter/material.dart\';
class MiladTheme {
  static const turquoise = Color(0xFF2AAFA1);
  static const lajvard = Color(0xFF0F2A44);
  static const sadef = Color(0xFFFDF8F0);
  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: sadef,
    colorScheme: ColorScheme.fromSeed(seedColor: turquoise, primary: turquoise, secondary: lajvard),
    appBarTheme: const AppBarTheme(backgroundColor: sadef, elevation: 0, centerTitle: true),
  );
}
