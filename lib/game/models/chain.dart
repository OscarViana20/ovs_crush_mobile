import 'dart:collection';

import '../utils/array_2d.dart';
import 'tile.dart';

enum ChainType {
  horizontal,
  vertical,
}

class Chain {
  Chain({
    this.length = 0,
    required this.type,
  });

  int length = 0;
  ChainType type;

  final HashMap<int, Tile> _tiles = HashMap<int, Tile>();

  List<Tile> get tiles => _tiles.values.toList();

  void addTile(Tile? tile) {
    if (tile != null) {
      _tiles.putIfAbsent(tile.hashCode, () => tile);
      length = _tiles.length;
    }
  }

  @override
  String toString() {
    List<String> details =
        tiles.map((Tile tile) => '[${tile.row},${tile.col}]').toList();
    return '$type${details.join(' - ')}';
  }
}

class ChainHelper {

  static Chain? checkVerticalChain(int row, int col, Array2d grid) {
    Chain chain = Chain(type: ChainType.vertical);
    int maxHeight = grid.height - 1;
    int minRow = (row - 5).clamp(0, maxHeight);
    int maxRow = (row + 5).clamp(0, maxHeight);
    int index = row;
    TileType? type = grid[row][col]?.type;

    // By default the tested tile is part of the chain
    chain.addTile(grid[row][col]);

    // Search Down
    index = row - 1;
    while (index >= minRow &&
        grid[index][col]?.type != null &&
        grid[index][col]?.type == type &&
        grid[index][col]?.type != TileType.empty) {
      chain.addTile(grid[index][col]);
      index--;
    }

    // Search Up
    index = row + 1;
    while (index <= maxRow &&
        grid[index][col]?.type != null &&
        grid[index][col]?.type == type &&
        grid[index][col]?.type != TileType.empty) {
      chain.addTile(grid[index][col]);
      index++;
    }

    // If the chain counts at least 3 tiles => return it
    return chain.length > 2 ? chain : null;
  }

  static Chain? checkHorizontalChain(int row, int col, Array2d grid) {
    Chain chain = Chain(type: ChainType.horizontal);
    int maxWidth = grid.width - 1;
    int minCol = (col - 5).clamp(0, maxWidth);
    int maxCol = (col + 5).clamp(0, maxWidth);
    int index = col;
    TileType? type = grid[row][col]?.type;

    // By default the tested tile is part of the chain
    chain.addTile(grid[row][col]);

    // Search Left
    index = col - 1;
    while (index >= minCol &&
        grid[index][col]?.type != null &&
        grid[row][index]?.type == type &&
        grid[row][index]?.type != TileType.empty) {
      chain.addTile(grid[row][index]);
      index--;
    }

    // Search Right
    index = col + 1;
    while (index <= maxCol &&
        grid[index][col]?.type != null &&
        grid[row][index]?.type == type &&
        grid[row][index]?.type != TileType.empty) {
      chain.addTile(grid[row][index]);
      index++;
    }

    // If the chain counts at least 3 tiles => return it
    return chain.length > 2 ? chain : null;
  }
}
