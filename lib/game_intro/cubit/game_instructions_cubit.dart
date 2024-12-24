import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/game_instructions_state.dart';

class GameInstructionsCubit extends Cubit<GameInstructionsState> {
  GameInstructionsCubit()
      : super(
          const GameInstructionsState(
            GameInstructionsStep.autoRun,
          ),
        );

  void updateStep(int index) {
    final step = GameInstructionsStep.values.elementAt(index);
    emit(GameInstructionsState(step));
  }
}
