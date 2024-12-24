import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/game_cubit.dart';
import '../cubit/objetive_cubit.dart';
import '../screens/game_screen.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (BuildContext context) => const Game(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GameCubit()),
        BlocProvider(create: (_) => ObjectiveCubit()),
      ],
      child: const GameScreen(),
    );
  }
}
