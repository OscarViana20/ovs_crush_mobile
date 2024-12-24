import 'row_col.dart';
import 'tile.dart';

enum TileAnimationType {
  moveDown,
  avalanche,
  newTile,
  chain,
  collapse,
}

class TileAnimation {
  TileAnimation({
    this.tileType,
    required this.to,
    required this.from,
    required this.tile,
    required this.delay,
    required this.animationType,
  });

  final TileType? tileType;
  final int delay;
  Tile tile;
  final RowCol to;
  final RowCol from;
  final TileAnimationType animationType;
}
