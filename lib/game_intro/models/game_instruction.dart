import 'package:equatable/equatable.dart';

import '../../common/utils/game_assets.dart';

class GameInstruction extends Equatable {
  const GameInstruction({
    required this.title,
    required this.assetPath,
    required this.description,
  });

  final String title;
  final String assetPath;
  final String description;

  @override
  List<Object> get props => [title, assetPath, description];
}

List<GameInstruction> get instructions {
  return [
    GameInstruction(
      title: 'Dash Auto-runs',
      assetPath: GameAssets.autoRunInstruction,
      description:
          'Welcome to Super Dash. In this game Dash runs automatically.',
    ),
    GameInstruction(
      title: 'Tap to Jump',
      assetPath: GameAssets.autoRunInstruction,
      description: 'Tap the screen to make Dash jump.',
    ),
    GameInstruction(
      title: 'Collect Eggs & Acorns',
      assetPath: GameAssets.autoRunInstruction,
      description: 'Get points by collecting eggs and acorns in the stage.',
    ),
    GameInstruction(
      title: 'Powerful Wings',
      assetPath: GameAssets.autoRunInstruction,
      description:
          'Collect the golden feather to power up Dash with Flutter. While in midair, tap to do a double jump and see Dash fly!',
    ),
    GameInstruction(
      title: 'Level Gates',
      assetPath: GameAssets.autoRunInstruction,
      description:
          'Advance through gates to face tougher challenges at higher stages.',
    ),
    GameInstruction(
      title: 'Avoid Bugs',
      assetPath: GameAssets.autoRunInstruction,
      description:
          'No one likes bugs! Jump to dodge them and avoid taking damage.',
    ),
  ];
}
