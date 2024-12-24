import 'package:flutter/material.dart';

class GameFilledButton extends StatelessWidget {
  const GameFilledButton({
    super.key,
    this.onPressed,
    this.width = 200.0,
    this.color1 = const Color(0xFF83C3F9),
    this.color2 = const Color(0xFF046DD6),
    required this.label,
  });

  final String label;
  final Color color1;
  final Color color2;
  final double width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        child: FilledButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
