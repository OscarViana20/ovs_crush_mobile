import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/utils/game_dialog.dart';
import '../../common/widgets/game_traslucent_background.dart';
import '../cubit/game_instructions_cubit.dart';
import '../models/game_instruction.dart';
import 'game_instructions_navigation.dart';

class GameInstructionsDialog extends StatefulWidget {
  const GameInstructionsDialog({super.key});

  @override
  State<GameInstructionsDialog> createState() => _GameInstructionsDialogState();
}

class _GameInstructionsDialogState extends State<GameInstructionsDialog> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameDialog(
      backgroundColor: Colors.black38,
      border: Border.all(color: Colors.white24),
      // imageProvider: AssetImage(GameAssets.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: pageController,
              itemCount: instructions.length,
              onPageChanged: context.read<GameInstructionsCubit>().updateStep,
              itemBuilder: (context, index) {
                final instruction = instructions.elementAt(index);
                return _CardContent(
                  title: instruction.title,
                  assetPath: instruction.assetPath,
                  description: instruction.description,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GameInstructionsNavigation(pageController: pageController),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.assetPath,
    required this.description,
  });

  final String title;
  final String assetPath;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        _CardImage(assetPath: assetPath),
        const SizedBox(height: 24),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.assetPath,
  });

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: GameTraslucentBackground(
        border: Border.all(color: Colors.white),
        gradient: const [
          Color(0xFFB1B1B1),
          Color(0xFF363567),
          Color(0xFFE2F8FA),
          Colors.white38,
        ],
        child: Positioned.fill(child: Image.asset(assetPath, height: 190)),
      ),
    );
  }
}
