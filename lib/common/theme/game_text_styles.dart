import 'package:flutter/material.dart';

class GameTextStyles {
  const GameTextStyles();

  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    labelLarge: labelLarge,
  );

  static const TextStyle _commonStyle = TextStyle(
    fontFamily: 'Google Sans',
    color: Colors.white,
    decorationColor: Colors.white,
  );

  static TextStyle get displayLarge => _commonStyle;

  static TextStyle get headlineSmall => _commonStyle;

  static TextStyle get labelLarge => _commonStyle;

  static TextStyle get bodyLarge =>
      _commonStyle.copyWith(fontSize: 17, height: 1.5);
}
