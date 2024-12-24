import 'dart:ui';

import 'package:flutter/material.dart';

import '../../common/animations/shine_effect.dart';
import '../../common/utils/game_constants.dart';
import '../../common/utils/game_assets.dart';
import '../../common/widgets/game_autor.dart';
import '../../common/widgets/game_filled_button.dart';
import '../../common/widgets/game_icon_button.dart';
import '../../common/paths/double_curved_container.dart';
import '../../common/widgets/game_shadowed_text.dart';
import '../../game/widgets/game.dart';
import '../widgets/game_info_dialog.dart';
import '../widgets/game_instructions.dart';

class GameIntroScreen extends StatelessWidget {
  const GameIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBody(context),
          const GameAutor(),
        ],
      ),
    );
  }

  Container _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(GameAssets.gameIntro),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: Colors.black.withOpacity(0), // Mantener transparente
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(height: 40.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: DoubleCurvedContainer(
            innerColor: Colors.blue,
            outerColor: Colors.blue[700]!,
            child: Stack(
              children: [
                const ShineEffect(offset: Offset(100.0, 100.0)),
                Align(
                  alignment: Alignment.center,
                  child: GameShadowedText(
                    fontSize: 28.0,
                    text: GameConstants.introTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: GameFilledButton(
            label: GameConstants.playBtn,
            onPressed: () => Navigator.of(context).push(
              Game.route(),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GameIconButton(
              icon: Icons.info,
              onPressed: () => Navigator.of(context).push(
                GameInfoDialog.route(),
              ),
            ),
            GameIconButton(
              icon: Icons.help,
              onPressed: () => Navigator.of(context).push(
                GameInstructions.route(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
