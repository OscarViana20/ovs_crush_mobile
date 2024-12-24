import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/iterables.dart';
import 'package:collection/collection.dart';

import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../models/objetive.dart';
import '../models/tile.dart';

class GameCubit extends Cubit<GameState> {
  static const double _kMaxTilesSize = 28.0;
  static const double _kMaxTilesPerRowAndColumn = 12.0;

  int _maxLevel = 0;
  int _levelNumber = 0;

  final List<Level> _levels = [];

  late GameController _gameController;

  double get kMaxTilesSize => _kMaxTilesSize;
  double get kMaxTilesPerRowAndColumn => _kMaxTilesPerRowAndColumn;

  GameController get gameController => _gameController;

  GameCubit() : super(GameState.initial()) {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _loadLevels();
    setLevel(1);
  }

  Future<void> _loadLevels() async {
    String jsonContent = await rootBundle.loadString("assets/levels.json");
    Map<dynamic, dynamic> list = json.decode(jsonContent);
    enumerate(list["levels"] as List).forEach((levelItem) {
      _levels.add(Level.fromJson(levelItem.value));
      _maxLevel++;
    });
  }

  void setLevel(int levelIndex) {
    _levelNumber = (levelIndex - 1).clamp(0, _maxLevel);
    _gameController = GameController(level: _levels[_levelNumber]);
    _gameController.shuffle();

    emit(state.copyWith(
      currentStep: GameStep.levelLoaded,
      level: _levels[_levelNumber],
    ));
  }

  void notifyTilesLoaded() {
    emit(state.copyWith(currentStep: GameStep.tilesLoaded));
  }

  void pushTileEvent(TileType tileType, int counter) {
    Objective? objective = gameController.level.objectives
        .firstWhereOrNull((o) => o.type == tileType);
    if (objective == null) return;

    objective.decrement(counter);
    emit(state.copyWith(
      currentStep: GameStep.tileEventUpdated,
      tileType: tileType,
      remaining: objective.count,
    ));

    bool isWon = _gameController.level.objectives.every((o) => o.count <= 0);
    if (isWon) {
      emit(state.copyWith(currentStep: GameStep.gameOver, won: true));
    }
  }

  void playMove() {
    int movesLeft = _gameController.level.decrementMove();
    emit(state.copyWith(
      currentStep: GameStep.movesLeftUpdated,
      movesLeft: movesLeft,
    ));

    if (movesLeft == 0) {
      emit(state.copyWith(currentStep: GameStep.gameOver, won: false));
    }
  }

  void reset() {
    _gameController.level.resetObjectives();
    emit(GameState.reset());
  }
}
