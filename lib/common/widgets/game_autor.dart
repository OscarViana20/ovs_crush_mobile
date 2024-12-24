import 'package:flutter/material.dart';

import '../utils/game_constants.dart';
import 'game_shadowed_text.dart';

class GameAutor extends StatelessWidget {
  const GameAutor({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GameShadowedText(text: GameConstants.creatorDescription),
      ),
    );
  }
}
