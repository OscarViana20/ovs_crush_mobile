import 'package:flutter/material.dart';

import '../models/level.dart';

class GameMovesCounter extends StatelessWidget {
  const GameMovesCounter({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.swap_horiz,
          color: Colors.black,
        ),
        const SizedBox(width: 8.0),
        Text(
          '${level.movesLeft}',
          style: const TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ],
    );
  }
}
