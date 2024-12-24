import 'tile.dart';

class ObjectiveEvent {
  final TileType type;
  final int remaining;

  ObjectiveEvent({
    required this.type,
    required this.remaining,
  });
}
