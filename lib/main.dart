import 'package:flutter/material.dart';

import 'common/theme/game_text_styles.dart';
import 'game_intro/screens/game_intro_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Crush',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          textTheme: GameTextStyles.textTheme,
        ),
        home: const GameIntroScreen(),
      );
  }
}
