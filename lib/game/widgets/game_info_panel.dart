import 'package:flutter/material.dart';

class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({
    super.key,
    this.width,
    required this.child,
    required this.padding,
    required this.alignment,
  });

  final double? width;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: 80.0,
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: 4.0,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
