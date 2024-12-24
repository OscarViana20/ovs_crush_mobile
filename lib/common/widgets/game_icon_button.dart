import 'package:flutter/material.dart';

import 'game_traslucent_background.dart';

class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    this.border,
    this.gradient,
    this.alignment,
    this.onPressed,
    this.size = 24.0,
    required this.icon,
  });

  final double? size;
  final IconData icon;
  final Border? border;
  final Alignment? alignment;
  final List<Color>? gradient;
  final VoidCallback? onPressed;

  static const _defaultGradient = LinearGradient(
    colors: [Colors.black, Colors.black26],
  );

  static final _defaultBorder = Border.all(
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return GameTraslucentBackground(
      border: border ?? _defaultBorder,
      gradient: gradient ?? _defaultGradient.colors,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(14.0),
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
