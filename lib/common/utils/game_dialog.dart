import 'package:flutter/material.dart';

import '../widgets/game_icon_button.dart';
import 'game_card.dart';

class GameDialog extends StatelessWidget {
  const GameDialog({
    super.key,
    required this.child,
    this.border,
    this.gradient,
    this.imageProvider,
    this.backgroundColor,
    this.showCloseButton = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final BoxBorder? border;
  final bool showCloseButton;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final BorderRadius borderRadius;
  final ImageProvider<Object>? imageProvider;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: GameCard(
        border: border,
        gradient: gradient,
        borderRadius: borderRadius,
        imageProvider: imageProvider,
        backgroundColor: backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCloseButton) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GameIconButton(
                      size: 15.0,
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
