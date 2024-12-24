import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    this.border,
    this.gradient,
    this.borderRadius,
    this.imageProvider,
    this.backgroundColor,
    required this.child,
  });

  final Widget child;
  final BoxBorder? border;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final BorderRadius? borderRadius;
  final ImageProvider<Object>? imageProvider;

  static const _defaulBackgroudColor = Color(0xE51B1B36);

  static const _defaultBorderRadius = BorderRadius.all(Radius.circular(24));

  static const _defaultGradient = LinearGradient(
    stops: [0.05, 0.5, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x51B1B1B1), Color(0x33363567), Color(0xE61B1B36)],
  );

  @override
  Widget build(BuildContext context) {
    final showImage = imageProvider != null;

    return Container(
      decoration: BoxDecoration(
        border: showImage ? null : border,
        borderRadius: borderRadius ?? _defaultBorderRadius,
        color: showImage ? null : backgroundColor ?? _defaulBackgroudColor,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? _defaultBorderRadius,
          gradient: showImage ? null : gradient ?? _defaultGradient,
          image: showImage
              ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
              : null,
        ),
        child: child,
      ),
    );
  }
}
