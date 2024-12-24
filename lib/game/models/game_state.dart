import 'package:equatable/equatable.dart';

import 'level.dart';
import 'tile.dart';

enum GameStep {
  initial,
  levelLoaded,
  tilesLoaded,
  tileEventUpdated,
  movesLeftUpdated,
  gameOver,
  gameReset,
}

class GameState extends Equatable {
  const GameState({
    required this.currentStep,
    this.level,
    this.tileType,
    this.remaining,
    this.movesLeft,
    this.won,
  });

  final GameStep currentStep;
  final Level? level;
  final TileType? tileType;
  final int? remaining;
  final int? movesLeft;
  final bool? won;

  GameState copyWith({
    GameStep? currentStep,
    Level? level,
    TileType? tileType,
    int? remaining,
    int? movesLeft,
    bool? won,
  }) {
    return GameState(
      currentStep: currentStep ?? this.currentStep,
      level: level ?? this.level,
      tileType: tileType ?? this.tileType,
      remaining: remaining ?? this.remaining,
      movesLeft: movesLeft ?? this.movesLeft,
      won: won ?? this.won,
    );
  }

  /// Game initial state.
  factory GameState.initial() => const GameState(currentStep: GameStep.initial);
  
  /// Restart state
  factory GameState.reset() => const GameState(currentStep: GameStep.gameReset);

  @override
  List<Object?> get props => [
        currentStep,
        level,
        tileType,
        remaining,
        movesLeft,
        won,
      ];
}
