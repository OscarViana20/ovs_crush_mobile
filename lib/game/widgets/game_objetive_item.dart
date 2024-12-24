import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/objetive_cubit.dart';
import '../models/level.dart';
import '../models/objetive.dart';
import '../models/tile.dart';
import '../utils/decoration_utils.dart';

class GameObjetiveItem extends StatefulWidget {
  const GameObjetiveItem({
    super.key,
    required this.level,
    required this.objective,
  });

  final Level level;
  final Objective objective;

  @override
  State<GameObjetiveItem> createState() => _GameObjetiveItemState();
}

class _GameObjetiveItemState extends State<GameObjetiveItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 32.0,
          height: 32.0,
          child: DecorationUtils.tileDecoration(widget.objective.type),
        ),
        BlocBuilder<ObjectiveCubit, Map<TileType, int>>(
          builder: (context, state) {
            return Text(
              '${state[widget.objective.type] ?? widget.objective.count}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }
}
