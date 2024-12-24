import 'package:flutter/material.dart';

import '../models/level.dart';
import 'game_info_panel.dart';
import 'game_moves_counter.dart';

class GameMovesRemaining extends StatelessWidget {
  const GameMovesRemaining({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  Widget build(BuildContext context) {
    return GameInfoPanel(
      width: 100,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Level: ${level.index}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GameMovesCounter(level: level),
        ],
      ),
    );
  }
}
