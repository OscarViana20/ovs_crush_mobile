import 'package:flutter/material.dart';

import '../models/tile.dart';

class AnimationSwapTiles extends StatefulWidget {
  const AnimationSwapTiles({
    super.key,
    required this.upTile,
    required this.downTile,
    required this.onComplete,
    required this.swapAllowed,
  });

  final Tile upTile;
  final Tile downTile;
  final bool swapAllowed;
  final VoidCallback onComplete;

  @override
  State<AnimationSwapTiles> createState() => _AnimationSwapTilesState();
}

class _AnimationSwapTilesState extends State<AnimationSwapTiles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            if (!widget.swapAllowed) {
              _controller.reverse();
            } else {
              widget.onComplete();
            }
          }

          if (status == AnimationStatus.dismissed) {
            widget.onComplete();
          }
        },
      );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deltaX = widget.upTile.x! - widget.downTile.x!;
    final double deltaY = widget.upTile.y! - widget.downTile.y!;

    return Stack(
      children: [
        Positioned(
          left: widget.downTile.x! + deltaX * _controller.value,
          top: widget.downTile.y! + deltaY * _controller.value,
          child: widget.downTile.widget,
        ),
        Positioned(
          left: widget.upTile.x! - deltaX * _controller.value,
          top: widget.upTile.y! - deltaY * _controller.value,
          child: widget.upTile.widget,
        ),
      ],
    );
  }
}
