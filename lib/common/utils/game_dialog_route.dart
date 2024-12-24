import 'package:flutter/material.dart';

class GameDialogRoute<T> extends PageRoute<T> {
  GameDialogRoute({
    required WidgetBuilder builder,
  }) : _builder = builder;

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black26;

  @override
  String? get barrierLabel => 'GameDialogRoute';

  @override
  Duration get transitionDuration => kThemeAnimationDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _builder(context);
  }
}