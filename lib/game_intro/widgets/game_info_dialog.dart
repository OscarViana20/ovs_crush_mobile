import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/theme/game_text_styles.dart';
import '../../common/utils/game_constants.dart';
import '../../common/utils/game_dialog.dart';
import '../../common/utils/game_dialog_route.dart';

class GameInfoDialog extends StatelessWidget {
  const GameInfoDialog({super.key});

  static PageRoute<void> route() {
    return GameDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameInfoDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameDialog(
      backgroundColor: Colors.black38,
      border: Border.all(color: Colors.grey),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Text(
                  GameConstants.aboutMatch3,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24.0),
                Text(
                  GameConstants.gameDescription,
                  textAlign: TextAlign.center,
                  style: GameTextStyles.bodyLarge.copyWith(fontSize: 20.0),
                ),
                const SizedBox(height: 24.0),
                RichText(
                  text: TextSpan(
                    text: GameConstants.webSiteTitle,
                    style: GameTextStyles.bodyLarge.copyWith(
                      color: const Color(0xFF398CF8),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF398CF8),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchURL(),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  void _launchURL() async {
    String url = 'https://github.com/flutter/super_dash';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
