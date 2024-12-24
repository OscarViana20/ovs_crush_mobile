import 'package:flutter/material.dart';

import '../models/level.dart';
import '../models/tile.dart';
import 'array_2d.dart';

class DecorationUtils {
  static Array2d<BoxDecoration> borderDecorations(
    int cols,
    int rows,
    Level level,
  ) {
    var decorations = Array2d<BoxDecoration>(cols + 1, rows + 1);

    for (int row = 0; row <= rows; row++) {
      for (int col = 0; col <= cols; col++) {
        int topLeft =
            (col > 0 && row < rows && level.grid[row][col - 1] != 'X') ? 1 : 0;
        int topRight =
            (col < cols && row < rows && level.grid[row][col] != 'X') ? 1 : 0;
        int bottomLeft =
            (col > 0 && row > 0 && level.grid[row - 1][col - 1] != 'X') ? 1 : 0;
        int bottomRight =
            (col < cols && row > 0 && level.grid[row - 1][col] != 'X') ? 1 : 0;

        int value =
            topLeft | (topRight << 1) | (bottomLeft << 2) | (bottomRight << 3);

        decorations[row][col] = (value != 0 && value != 6 && value != 9)
            ? BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/board/border_$value.png'),
                ),
              )
            : null;
      }
    }

    return decorations;
  }

  static Widget tileDecoration(TileType? type, [String path = ""]) {
    String imageAsset = path;
    if (imageAsset == "") {
      switch (type) {
        case TileType.wall:
          imageAsset = "deco/wall.png";
          break;

        case TileType.bomb:
          imageAsset = "bombs/mine.png";
          break;

        case TileType.flare:
          imageAsset = "bombs/tnt.png";
          break;

        case TileType.wrapped:
          imageAsset = "tiles/multicolor.png";
          break;

        case TileType.fireball:
          imageAsset = "bombs/rocket.png";
          break;

        case TileType.blue_v:
        case TileType.blue_h:
        case TileType.red_v:
        case TileType.red_h:
        case TileType.green_v:
        case TileType.green_h:
        case TileType.orange_v:
        case TileType.orange_h:
        case TileType.purple_v:
        case TileType.purple_h:
        case TileType.yellow_v:
        case TileType.yellow_h:
          imageAsset = "bombs/${type!.name}.png";
          break;

        default:
          try {
            imageAsset = "tiles/${type!.name}.png";
          } catch (e) {
            return Container();
          }
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.contain,
          image: AssetImage('assets/images/$imageAsset'),
        ),
      ),
    );
  }
}
