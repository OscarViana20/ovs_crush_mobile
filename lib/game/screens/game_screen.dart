import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../animations/animation_chain.dart';
import '../animations/animation_combo_collapse.dart';
import '../animations/animation_combo_three.dart';
import '../animations/animation_swap_tiles.dart';
import '../../common/utils/game_assets.dart';
import '../../common/widgets/game_autor.dart';
import '../../common/widgets/game_icon_button.dart';
import '../controllers/game_controller.dart';
import '../cubit/game_cubit.dart';
import '../models/combo.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../models/row_col.dart';
import '../models/tile.dart';
import '../utils/animations_resolver.dart';
import '../utils/gesture_utils.dart';
import '../widgets/game_board.dart';
import '../widgets/game_moves_remaining.dart';
import '../widgets/game_objetives.dart';
import '../widgets/game_tiles.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  bool _allowGesture = false;

  bool? gestureStarted;
  Tile? gestureFromTile;
  RowCol? gestureFromRowCol;
  Offset? gestureOffsetStart;
  OverlayEntry? _overlayEntryFromTile;
  OverlayEntry? _overlayEntryAnimateSwapTiles;

  final double minGestureDelta = 2.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _allowGesture = true;
    });
  }

  @override
  void dispose() {
    _overlayEntryFromTile?.remove();
    _overlayEntryAnimateSwapTiles?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        if (state.level == null) {
          return Scaffold(body: _buildGameContainer());
        }
        return Scaffold(
          floatingActionButton: GameIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          body: _buildGameContainer(
            child: GestureDetector(
              onPanDown: (details) => _onPanDown(details, state.level!),
              onPanStart: _onPanStart,
              onPanEnd: _onPanEnd,
              onPanUpdate: (details) => _onPanUpdate(details, state.level!),
              onTap: () => _onTap(state.level!),
              onTapUp: _onPanEnd,
              child: Stack(
                children: [
                  const GameAutor(),
                  GameMovesRemaining(level: state.level!),
                  GameObjetives(level: state.level!),
                  GameBoard(level: state.level!),
                  GameTiles(level: state.level!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameContainer({Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(GameAssets.gameScreen),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: child,
      ),
    );
  }

  RowCol _rowColFromGlobalPosition(Offset globalPosition, Level level) {
    final double top = globalPosition.dy - level.boardTop;
    final double left = globalPosition.dx - level.boardLeft;
    return RowCol(
      col: (left / level.tileWidth).floor(),
      row: level.numberOfRows - (top / level.tileHeight).floor() - 1,
    );
  }

  void _showComboTilesForAnimation(Combo combo, bool visible) {
    for (var tile in combo.tiles) {
      tile.visible = visible;
    }
    setState(() {});
  }

  Future<dynamic> _animateCombo(Combo combo, Level level) async {
    if (combo.type == ComboType.none ||
        combo.type == ComboType.one ||
        combo.type == ComboType.two) {
      return;
    }

    var completer = Completer();
    OverlayEntry? overlayEntry;

    _showComboTilesForAnimation(combo, false);

    if (combo.type == ComboType.three) {
      overlayEntry = OverlayEntry(
        opaque: false,
        builder: (_) => AnimationComboThree(
          combo: combo,
          onComplete: () {
            overlayEntry?.remove();
            overlayEntry = null;
            completer.complete(null);
          },
        ),
      );
    } else {
      Tile? resultingTile = Tile(
        col: combo.commonTile!.col,
        row: combo.commonTile!.row,
        type: combo.resultingTileType,
        level: level,
        depth: 0,
      );
      resultingTile.build();
      overlayEntry = OverlayEntry(
        opaque: false,
        builder: (_) => AnimationComboCollapse(
          combo: combo,
          resultingTile: resultingTile!,
          onComplete: () {
            resultingTile = null;
            overlayEntry?.remove();
            overlayEntry = null;
            completer.complete(null);
          },
        ),
      );
    }
    Overlay.of(context).insert(overlayEntry!);
    return completer.future;
  }

  Future<dynamic> _playAllAnimations(GameCubit gameCubit, Level level) async {
    var completer = Completer();

    var resolver = AnimationsResolver(gameCubit: gameCubit, level: level);
    resolver.resolve();

    if (resolver.involvedCells.isEmpty) {
      completer.complete(null);
    }

    var sequences = resolver.getAnimationsSequences();
    int pendingSequences = sequences.length;

    for (var rowCol in resolver.involvedCells) {
      gameCubit.gameController.grid[rowCol.row][rowCol.col].visible = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<OverlayEntry> overlayEntries = <OverlayEntry>[];

      for (var animationSequence in sequences) {
        overlayEntries.add(
          OverlayEntry(
            opaque: false,
            builder: (BuildContext context) {
              return AnimationChain(
                level: level,
                animationSequence: animationSequence,
                onComplete: () {
                  pendingSequences--;
                  if (pendingSequences == 0) {
                    for (var entry in overlayEntries) {
                      entry.remove();
                    }
                    gameCubit.gameController.refreshGridAfterAnimations(
                      resolver.resultingGridInTermsOfTileTypes,
                      resolver.involvedCells,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      completer.complete(null);
                    });
                    setState(() {});
                  }
                },
              );
            },
          ),
        );
      }
      Overlay.of(context).insertAll(overlayEntries);
    });

    setState(() {});
    return completer.future;
  }

  void _onPanDown(DragDownDetails details, Level level) {
    if (!_allowGesture) return;

    // Determine the [row,col] from touch position
    RowCol rowCol = _rowColFromGlobalPosition(details.globalPosition, level);

    // Ignore if we touched outside the grid
    if (rowCol.row < 0 ||
        rowCol.row >= level.numberOfRows ||
        rowCol.col < 0 ||
        rowCol.col >= level.numberOfCols) return;

    // Check if the [row,col] corresponds to a possible swap
    GameController gameController = context.read<GameCubit>().gameController;
    Tile? selectedTile = gameController.grid[rowCol.row][rowCol.col];

    gestureStarted = false;
    gestureFromTile = null;
    gestureFromRowCol = null;
    gestureOffsetStart = null;

    if (selectedTile != null && selectedTile.canMove) {
      gestureFromRowCol = rowCol;
      gestureFromTile = selectedTile;
      _overlayEntryFromTile = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return Positioned(
              left: gestureFromTile!.x,
              top: gestureFromTile!.y,
              child: Transform.scale(
                scale: 1.1,
                child: gestureFromTile!.widget,
              ),
            );
          });
      Overlay.of(context).insert(_overlayEntryFromTile!);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Level level) {
    if (!_allowGesture) return;

    if (gestureStarted == true) {
      int deltaRow = 0;
      int deltaCol = 0;
      bool test = false;
      Offset delta = details.globalPosition - gestureOffsetStart!;

      if (GestureUtils.isHorizontalMove(delta, minGestureDelta)) {
        // horizontal move
        deltaCol = delta.dx.floor().sign;
        test = true;
      } else if (GestureUtils.isVerticalMove(delta, minGestureDelta)) {
        // vertical move
        deltaRow = -delta.dy.floor().sign;
        test = true;
      }

      if (test == true) {
        RowCol rowCol = RowCol(
          row: gestureFromRowCol!.row + deltaRow,
          col: gestureFromRowCol!.col + deltaCol,
        );

        if (rowCol.col < 0 ||
            rowCol.col >= level.numberOfCols ||
            rowCol.row < 0 ||
            rowCol.row >= level.numberOfRows) return;

        GameCubit gameCubit = context.read<GameCubit>();
        GameController gameController = gameCubit.gameController;

        Tile? destTile = gameController.grid[rowCol.row][rowCol.col];

        bool canBePlayed = destTile != null &&
            (destTile.canMove || destTile.type == TileType.empty);

        if (canBePlayed) {
          // We need to test the swap
          bool swapAllowed = gameController.swapContains(
            gestureFromTile!,
            destTile,
          );

          _allowGesture = false;
          _overlayEntryFromTile?.remove();
          _overlayEntryFromTile = null;

          Tile upTile = gestureFromTile!.cloneForAnimation();
          Tile downTile = destTile.cloneForAnimation();

          gameController.grid[rowCol.row][rowCol.col].visible = false;

          gameController.grid[gestureFromRowCol!.row][gestureFromRowCol!.col]
              .visible = false;

          setState(() {});

          _overlayEntryAnimateSwapTiles = OverlayEntry(
            opaque: false,
            builder: (BuildContext context) {
              return AnimationSwapTiles(
                upTile: upTile,
                downTile: downTile,
                swapAllowed: swapAllowed,
                onComplete: () async {
                  gameController.grid[rowCol.row][rowCol.col].visible = true;

                  gameController
                      .grid[gestureFromRowCol!.row][gestureFromRowCol!.col]
                      .visible = true;

                  _overlayEntryAnimateSwapTiles?.remove();
                  _overlayEntryAnimateSwapTiles = null;

                  if (swapAllowed) {
                    // Remember if the tile we move is a bomb
                    bool isSourceTileABomb = Tile.isBomb(
                      gestureFromTile!.type!,
                    );

                    // Swap the 2 tiles
                    gameController.swapTiles(gestureFromTile!, destTile);

                    // Get the tiles that need to be removed, following the swap
                    // We need to get the tiles from all possible combos
                    Combo comboOne = gameController.getCombo(
                      gestureFromTile!.row,
                      gestureFromTile!.col,
                    );

                    Combo comboTwo = gameController.getCombo(
                      destTile.row,
                      destTile.col,
                    );

                    // Wait for both animations to complete
                    await Future.wait([
                      _animateCombo(comboOne, level),
                      _animateCombo(comboTwo, level)
                    ]);

                    // Resolve the combos
                    gameController.resolveCombo(comboOne, gameCubit);
                    gameController.resolveCombo(comboTwo, gameCubit);

                    // If the tile we moved is a bomb, we need to process the explosion
                    if (isSourceTileABomb) {
                      gameController.proceedWithExplosion(
                        Tile(
                          row: destTile.row,
                          col: destTile.row,
                          type: gestureFromTile!.type,
                        ),
                        gameCubit,
                      );
                    }

                    await _playAllAnimations(gameCubit, level);

                    // Once this is all done, we need to recalculate all the possible swaps
                    gameController.identifySwaps();

                    // Record the fact that we have played a move
                    gameCubit.playMove();

                    if (!gameController.stillMovesToPlay()) {
                      // No moves left
                      // await _showReshufflingSplash();
                      gameController.reshuffling();
                      setState(() {});
                    }

                    // Make sure there is a correct delay before refreshing the screen
                    await Future.delayed(const Duration(milliseconds: 500));
                  }

                  // 7. Reset
                  _allowGesture = true;
                  _onPanEnd(null);
                  setState(() {});
                },
              );
            },
          );
          Overlay.of(context).insert(_overlayEntryAnimateSwapTiles!);
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!_allowGesture) return;

    if (gestureFromTile != null) {
      gestureStarted = true;
      gestureOffsetStart = details.globalPosition;
    }
  }

  void _onPanEnd(_) {
    if (!_allowGesture) return;

    gestureStarted = false;
    gestureOffsetStart = null;
    _overlayEntryFromTile?.remove();
    _overlayEntryFromTile = null;
  }

  void _onTap(Level level) {
    if (!_allowGesture) return;

    if (gestureFromTile != null && Tile.isBomb(gestureFromTile!.type!)) {
      _allowGesture = false;

      GameCubit gameCubit = context.read<GameCubit>();

      // Proceed with explosion
      gameCubit.gameController.proceedWithExplosion(
        gestureFromTile!,
        gameCubit,
      );

      // Rebuild the board and proceed with animations
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await _playAllAnimations(gameCubit, level);

          // Once this is all done, we need to recalculate all the possible swaps
          gameCubit.gameController.identifySwaps();

          // The user may now play
          _allowGesture = true;

          // Record the fact that we have played a move
          gameCubit.playMove();

          // Check if there are still moves to play
          if (!gameCubit.gameController.stillMovesToPlay()) {
            // await _showReshufflingSplash();
            gameCubit.gameController.reshuffling();
            setState(() {});
          }
        },
      );
    }
  }
}
