import 'package:flutter/material.dart';

class GameShadowedText extends StatelessWidget {
  const GameShadowedText({
    super.key,
    required this.text,
    this.fontSize = 13.0,
    this.shadowOpacity = 1.0,
    this.color = Colors.white,
    this.offset = const Offset(1.0, 1.0),
  });

  final String text;
  final Color color;
  final Offset offset;
  final double fontSize;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: offset,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(shadowOpacity),
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
