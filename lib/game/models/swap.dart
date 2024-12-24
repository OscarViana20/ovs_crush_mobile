import 'tile.dart';

class Swap extends Object {
  Swap({
    required this.from,
    required this.to,
  });

  Tile from;
  Tile to;

  @override
  int get hashCode => from.hashCode * 1000 + to.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) || other.hashCode == hashCode;
  }

  @override
  String toString() => '[${from.row}][${from.col}] => [${to.row}][${to.col}]';
}
