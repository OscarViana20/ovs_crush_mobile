import 'dart:collection';

import 'chain.dart';
import 'tile.dart';

enum ComboType {
  none,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
}

class Combo {
  Tile? oneTile;
  Tile? commonTile;
  TileType? resultingTileType;

  ComboType _type = ComboType.none;
  final HashMap<int, Tile> _tiles = HashMap<int, Tile>();

  ComboType get type => _type;
  List<Tile> get tiles => UnmodifiableListView(_tiles.values.toList());

  Combo(Chain? horizontalChain, Chain? verticalChain, int row, int col) {
    if (horizontalChain == null && verticalChain == null) return;

    _processChain(horizontalChain);
    _processChain(verticalChain);
    _setCommonTile(row, col);

    _type = ComboType.values[_tiles.length];

    _setResultingTileType(horizontalChain);
  }

  void _processChain(Chain? chain) {
    chain?.tiles.forEach((Tile tile) {
      if (commonTile == null && _tiles.containsKey(tile.hashCode)) {
        commonTile = tile;
      }
      _tiles.putIfAbsent(tile.hashCode, () => tile);
      oneTile ??= tile;
    });
  }

  void _setCommonTile(int row, int col) {
    if (_tiles.length > 3 && commonTile == null) {
      for (var tile in _tiles.values) {
        if (tile.row == row && tile.col == col) {
          commonTile = tile;
        }
      }
    }
  }

  void _setResultingTileType(Chain? horizontalChain) {
    switch (_tiles.length) {
      case 4:
        resultingTileType = _combo4Type(horizontalChain);
        break;
      case 5:
        resultingTileType = TileType.wrapped;
        break;
      case 6:
        resultingTileType = TileType.bomb;
        break;
      case 7:
        resultingTileType = TileType.fireball;
        break;
    }
  }

  TileType _combo4Type(Chain? horizontalChain) {
    if (oneTile == null) return TileType.flare;
    final isHorizontal = horizontalChain != null;

    switch (oneTile!.type) {
      case TileType.red:
        return isHorizontal ? TileType.red_h : TileType.red_v;
      case TileType.green:
        return isHorizontal ? TileType.green_h : TileType.green_v;
      case TileType.blue:
        return isHorizontal ? TileType.blue_h : TileType.blue_v;
      case TileType.orange:
        return isHorizontal ? TileType.orange_h : TileType.orange_v;
      case TileType.yellow:
        return isHorizontal ? TileType.yellow_h : TileType.yellow_v;
      case TileType.purple:
        return isHorizontal ? TileType.purple_h : TileType.purple_v;
      default:
        return TileType.flare;
    }
  }
}
