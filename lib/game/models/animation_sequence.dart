import 'tile.dart';
import 'tile_animation.dart';

class AnimationSequence {
  AnimationSequence({
    required this.tileType,
    required this.startDelay,
    required this.endDelay,
    required this.animations,
  });
  
  int startDelay;
  int endDelay;
  TileType tileType;
  List<TileAnimation> animations;
}