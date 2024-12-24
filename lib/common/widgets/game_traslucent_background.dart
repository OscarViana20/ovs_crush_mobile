import 'package:flutter/material.dart';

class GameTraslucentBackground extends StatelessWidget {
  const GameTraslucentBackground({
    super.key,
    this.border,
    this.borderRadius,
    required this.child,
    required this.gradient,
    this.shape = BoxShape.circle,
  });

  final Widget child;
  final BoxShape shape;
  final Border? border;
  final List<Color> gradient;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: shape,
                border: border,
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
