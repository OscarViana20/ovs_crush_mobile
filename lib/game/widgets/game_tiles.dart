import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/game_cubit.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../models/tile.dart';
import '../utils/array_2d.dart';

class GameTiles extends StatelessWidget {
  const GameTiles({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        /* if (state.currentStep != GameStep.tilesLoaded) {
          return const SizedBox.shrink();
        } */
        return Stack(children: _buildTiles(context));
      },
    );
  }

  List<Widget> _buildTiles(BuildContext context) {
    List<Widget> tiles = [];
    Array2d<Tile> grid = context.read<GameCubit>().gameController.grid;
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        final Tile tile = grid[row][col];
        final TileType? tileType = tile.type;
        if (tileType != TileType.empty &&
            tileType != TileType.forbidden &&
            tile.visible) {
          tile.setPosition();
          tiles.add(Positioned(left: tile.x, top: tile.y, child: tile.widget));
        }
      }
    }
    return tiles;
  }
}
