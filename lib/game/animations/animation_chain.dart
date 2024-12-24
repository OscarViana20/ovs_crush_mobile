import 'package:flutter/material.dart';

import '../models/animation_sequence.dart';
import '../models/level.dart';
import '../models/tile_animation.dart';

class AnimationChain extends StatefulWidget {
  const AnimationChain({
    super.key,
    required this.level,
    this.onComplete,
    this.animationSequence,
  });

  final Level level;
  final VoidCallback? onComplete;
  final AnimationSequence? animationSequence;

  @override
  State<AnimationChain> createState() => _AnimationChainState();
}

class _AnimationChainState extends State<AnimationChain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int delayInMs = 3;
  final int normalDurationInMs = 300;
  final List<Animation<double>> _animations = <Animation<double>>[];

  int totalDurationInMs = 0;

  void _initializeAnimations() {
    for (var tileAnimation in widget.animationSequence!.animations) {
      int start = tileAnimation.delay * delayInMs;
      int end = start + normalDurationInMs;
      final double ratioStart = start / totalDurationInMs;
      final double ratioEnd = end / totalDurationInMs;

      _animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(ratioStart, ratioEnd, curve: Curves.ease),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    totalDurationInMs = (widget.animationSequence!.endDelay + 1) * delayInMs +
        normalDurationInMs;

    _controller = AnimationController(
      duration: Duration(milliseconds: totalDurationInMs),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            if (widget.onComplete != null) {
              widget.onComplete?.call();
            }
          }
        },
      );

    _initializeAnimations();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalAnimations = widget.animationSequence!.animations.length;
    int index = totalAnimations - 1;

    TileAnimation firstAnimation = widget.animationSequence!.animations[0];
    late Widget theWidget;

    while (index >= 0) {
      theWidget = _buildSubAnimationFactory(
        index,
        widget.animationSequence!.animations[index],
        firstAnimation.tile.widget,
      );
      index--;
    }

    return Stack(
      children: [
        Positioned(
          left: firstAnimation.tile.x,
          top: firstAnimation.tile.y,
          child: theWidget,
        ),
      ],
    );
  }

  Widget _buildSubAnimationFactory(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    Widget widget;
    switch (tileAnimation.animationType) {
      case TileAnimationType.newTile:
        widget =
            _buildSubAnimationAppearance(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.moveDown:
        widget = _buildSubAnimationMoveDown(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.avalanche:
        widget = _buildSubAnimationSlide(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.collapse:
        widget = _buildSubAnimationCollapse(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.chain:
        widget = _buildSubAnimationChain(index, tileAnimation, childWidget);
        break;
    }
    return widget;
  }

  //
  // The appearance consists in an initial translated (-Y) position,
  // followed by a move down
  //
  Widget _buildSubAnimationAppearance(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    return Transform.translate(
      offset: Offset(
        0.0,
        -widget.level.tileHeight +
            widget.level.tileHeight * _animations[index].value,
      ),
      child: _buildSubAnimationMoveDown(index, tileAnimation, childWidget),
    );
  }

  //
  // A move down animation consists in moving the tile down to its final position
  //
  Widget _buildSubAnimationMoveDown(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    final double distance = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;

    return Transform.translate(
      offset: Offset(0.0, -_animations[index].value * distance),
      child: childWidget,
    );
  }

  //
  // A slide consists in moving the tile horizontally
  //
  Widget _buildSubAnimationSlide(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    final double distanceX = (tileAnimation.to.col - tileAnimation.from.col) *
        widget.level.tileWidth;
    final double distanceY = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;
    return Transform.translate(
      offset: Offset(
        _animations[index].value * distanceX,
        -_animations[index].value * distanceY,
      ),
      child: childWidget,
    );
  }

  //
  // A chain consists in making tiles disappear
  //
  Widget _buildSubAnimationChain(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    return Transform.scale(
      scale: (1.0 - _animations[index].value),
      child: childWidget,
    );
  }

  //
  // A collapse consists in moving the tile to the destination tile position
  //
  Widget _buildSubAnimationCollapse(
    int index,
    TileAnimation tileAnimation,
    Widget childWidget,
  ) {
    final double distanceX = (tileAnimation.to.col - tileAnimation.from.col) *
        widget.level.tileWidth;
    final double distanceY = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;
    return Transform.translate(
      offset: Offset(
        _animations[index].value * distanceX,
        -_animations[index].value * distanceY,
      ),
      child: childWidget,
    );
  }
}
