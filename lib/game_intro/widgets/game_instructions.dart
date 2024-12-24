import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/utils/game_dialog_route.dart';
import '../cubit/game_instructions_cubit.dart';
import 'game_instructions_dialog.dart';

class GameInstructions extends StatelessWidget {
  const GameInstructions({super.key});

  static PageRoute<void> route() {
    return GameDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameInstructions(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameInstructionsCubit(),
      child: const GameInstructionsDialog(),
    );
  }
}
