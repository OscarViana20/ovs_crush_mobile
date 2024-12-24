import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/game_icon_button.dart';
import '../cubit/game_instructions_cubit.dart';
import '../models/game_instructions_state.dart';

class GameInstructionsNavigation extends StatelessWidget {
  const GameInstructionsNavigation({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final currentStep = context.select(
      (GameInstructionsCubit cubit) => cubit.state.currentStep,
    );
    final isFirstStep = currentStep == GameInstructionsStep.values.first;
    final isLastStep = currentStep == GameInstructionsStep.values.last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final step in GameInstructionsStep.values)
              _PageIndicator(step: step),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Opacity(
              opacity: isFirstStep ? 0.5 : 1,
              child: GameIconButton(
                icon: Icons.arrow_back,
                onPressed: isFirstStep
                    ? null
                    : () => pageController.previousPage(
                          curve: Curves.easeIn,
                          duration: const Duration(milliseconds: 400),
                        ),
              ),
            ),
            GameIconButton(
              icon: isLastStep ? Icons.check : Icons.arrow_forward,
              onPressed: isLastStep
                  ? Navigator.of(context).pop
                  : () => pageController.nextPage(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 400),
                      ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.step,
  });

  final GameInstructionsStep step;

  static const inactiveGradient = [Color(0xFFE3F2FD), Colors.white];

  static const activeGradient = [Colors.blue, Colors.blue];

  @override
  Widget build(BuildContext context) {
    final currentStep = context.select(
      (GameInstructionsCubit cubit) => cubit.state.currentStep,
    );
    return Container(
      height: 12,
      width: step == currentStep ? 24 : 12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        shape: step == currentStep ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: step == currentStep ? BorderRadius.circular(10) : null,
        gradient: LinearGradient(
          colors: step == currentStep ? activeGradient : inactiveGradient,
        ),
      ),
    );
  }
}
