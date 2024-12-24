import 'package:flutter/material.dart';

import '../models/level.dart';
import '../models/objetive.dart';
import 'game_info_panel.dart';
import 'game_objetive_item.dart';

class GameObjetives extends StatelessWidget {
  const GameObjetives({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  Widget build(BuildContext context) {
    var objectiveWidgets = level.objectives.map(
      (Objective objetive) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GameObjetiveItem(level: level, objective: objetive),
        );
      },
    ).toList();

    return GameInfoPanel(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 10.0, right: 10.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: objectiveWidgets),
    );
  }
}
