import 'dart:ui';

class GestureUtils {
  static bool isHorizontalMove(Offset delta, double minGestureDelta) {
    return delta.dx.abs() > delta.dy.abs() && delta.dx.abs() > minGestureDelta;
  }

  static bool isVerticalMove(Offset delta, double minGestureDelta) {
    return delta.dy.abs() > minGestureDelta;
  }
}
