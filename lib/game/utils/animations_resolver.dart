import 'dart:math' as math;

import 'package:quiver/iterables.dart';

import '../cubit/game_cubit.dart';
import '../models/animation_sequence.dart';
import '../models/avalanche_test.dart';
import '../models/chain.dart';
import '../models/combo.dart';
import '../models/level.dart';
import '../models/row_col.dart';
import '../models/tile.dart';
import '../models/tile_animation.dart';
import 'array_2d.dart';

enum CellState {
  forbidden,
  empty,
  occupied,
}

class AnimationsResolver {
  AnimationsResolver({
    required this.level,
    required this.gameCubit,
  }) {
    rows = level.numberOfRows;
    cols = level.numberOfCols;
  }

  final Level level;
  final GameCubit gameCubit;

  late int rows;
  late int cols;
  late Array2d<Tile> _tiles;
  late Array2d<int> _identities;
  late Array2d<TileType> _types;
  late Array2d<CellState> _state;
  late List<List<AvalancheTest>> _avalanches;
  late Map<int, List<int>> _animationsIdentitiesPerDelay;
  late Map<int, Map<int, TileAnimation>> _animationsPerIdentityAndDelay;

  int longestDelay = 0;
  int _nextIdentity = 0;
  final Set<RowCol> _lastMoves = <RowCol>{};
  final Set<RowCol> _involvedCells = <RowCol>{};

  Set<RowCol> get involvedCells => _involvedCells;
  Array2d<Tile> get resultingGridInTermsOfTiles => _tiles;
  Array2d<TileType> get resultingGridInTermsOfTileTypes => _types;

  // Registers an animation
  void _registerAnimation(int identity, int delay, TileAnimation animation) {
    if (_animationsPerIdentityAndDelay[identity] == null) {
      _animationsPerIdentityAndDelay[identity] = <int, TileAnimation>{};
    }

    if (_animationsIdentitiesPerDelay[delay] == null) {
      _animationsIdentitiesPerDelay[delay] = <int>[];
    }

    _animationsPerIdentityAndDelay[identity]![delay] = animation;
    _animationsIdentitiesPerDelay[delay]!.add(identity);
  }

  void resolve() {
    _nextIdentity = 0;
    _tiles = Array2d<Tile>(rows, cols);
    _types = Array2d<TileType>(rows, cols);
    _identities = Array2d<int>(rows, cols);
    _state = Array2d<CellState>(rows, cols);

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (level.grid[row][col] == "X") {
          _tiles[row][col] = null;
          _types[row][col] = TileType.forbidden;
          _state[row][col] = CellState.forbidden;
        } else {
          Tile tile = gameCubit.gameController.grid[row][col];
          _tiles[row][col] = tile;
          if (tile.type == TileType.empty) {
            _types[row][col] = TileType.empty;
            _state[row][col] = CellState.empty;
          } else if (tile.canMove) {
            _types[row][col] = tile.type;
            _state[row][col] = CellState.occupied;
          } else {
            _types[row][col] = tile.type;
            _state[row][col] = CellState.forbidden;
          }
        }
        // Give an identity to each cell
        _identities[row][col] = _nextIdentity++;
      }
    }

    _avalanches = List<List<AvalancheTest>>.generate(
      cols,
      (int index) => <AvalancheTest>[],
    );

    _animationsIdentitiesPerDelay = <int, List<int>>{};
    _animationsPerIdentityAndDelay = <int, Map<int, TileAnimation>>{};

    int delay = 0;
    longestDelay = 0;

    bool continueLoop;
    bool loopBasedOnAvalanche;

    do {
      do {
        _lastMoves.clear();
        continueLoop = false;
        delay = _resolveCombos(delay);

        for (int column = 0; column < cols; column++) {
          // Start by processing the avalanches
          bool somethingHappens = _processAvalanches(column, delay);

          // Then process the moves inside a column
          int newDelay = _processColumn(column, delay);
          somethingHappens |= (newDelay != delay);

          // If something happens, we need to continue
          if (somethingHappens) {
            continueLoop = true;
            longestDelay = math.max(longestDelay, newDelay);
          }
        }
        delay = longestDelay;
      } while (continueLoop);

      loopBasedOnAvalanche = false;
      int newDelay = _postAvalanches(delay);
      if (newDelay != delay) {
        loopBasedOnAvalanche = true;
        longestDelay = math.max(longestDelay, newDelay);
      }
    } while (loopBasedOnAvalanche);
  }

  //
  // Post-Avalanches
  //
  int _postAvalanches(int startDelay) {
    int newDelay = startDelay;
    bool leaveLoops = false;

    for (int row = 0; row < rows - 1 && !leaveLoops; row++) {
      for (int col = 0; col < cols && !leaveLoops; col++) {
        if (_state[row][col] == CellState.empty) {
          // This cell is empty.  Is there an available occupied cell that could fill this one ?
          final bool leftCol = (col > 0);
          final bool rightCol = (col < cols - 1);
          RowCol? from;

          if (leftCol && _state[row + 1][col - 1] == CellState.occupied) {
            // There is an available cell on the top-left hand of this cell
            from = RowCol(row: row + 1, col: col - 1);
          } else if (rightCol &&
              _state[row + 1][col + 1] == CellState.occupied) {
            // There is an available cell on the top-right hand of this cell
            from = RowCol(row: row + 1, col: col + 1);
          }

          if (from != null) {
            // Register the avalanche animation
            Tile newTile = Tile.clone(_tiles[from.row][from.col]);
            RowCol to = RowCol(row: row, col: col);

            _registerAnimation(
              _identities[from.row][from.col],
              newDelay,
              TileAnimation(
                animationType: TileAnimationType.avalanche,
                delay: newDelay,
                from: from,
                to: to,
                tileType: _types[from.row][from.col],
                tile: _tiles[from.row][from.col],
              ),
            );

            // Register the last move
            _lastMoves.add(to);

            // We now need to re-align the post-avalanche status
            newTile.row = row;
            newTile.col = col;
            newTile.build();

            _tiles[row][col] = newTile;
            _state[row][col] = CellState.occupied;
            _types[row][col] = newTile.type;

            _tiles[from.row][from.col] = null;
            _state[from.row][from.col] = CellState.empty;
            _types[from.row][from.col] = TileType.empty;

            // increase the next delay
            newDelay += 10;

            // Leave all the loops
            leaveLoops = true;
          }
        }
      }
    }

    return newDelay;
  }

  //
  // Resolves any potential combos
  //
  int _resolveCombos(int startDelay) {
    int delay = startDelay;
    bool hasCombo = false;

    for (var rowCol in _lastMoves) {
      Chain? verticalChain = ChainHelper.checkVerticalChain(
        rowCol.row,
        rowCol.col,
        _tiles,
      );
      Chain? horizontalChain = ChainHelper.checkHorizontalChain(
        rowCol.row,
        rowCol.col,
        _tiles,
      );

      // Check if there is a combo
      Combo combo = Combo(
        horizontalChain,
        verticalChain,
        rowCol.row,
        rowCol.col,
      );

      if (combo.type != ComboType.none) {
        // We found a combo.  We therefore need to take appropriate actions
        TileAnimationType animationType;
        RowCol? from;
        RowCol? to;

        // Recall that there is at least one combo
        hasCombo = true;

        if (combo.type == ComboType.three) {
          animationType = TileAnimationType.chain;
        } else {
          animationType = TileAnimationType.collapse;

          if (combo.commonTile == null) {
            // We assume the common tile is the one, present at current location
            to = RowCol(row: rowCol.row, col: rowCol.col);
          } else {
            // When we are collapsing, the tiles move to the position of the commonTile
            to = RowCol(row: combo.commonTile!.row, col: combo.commonTile!.col);
          }
        }

        // We need to register the animations (combo)
        for (var tile in combo.tiles) {
          from = RowCol(row: tile.row, col: tile.col);

          if (to != null) {
            _registerAnimation(
              _identities[tile.row][tile.col],
              delay,
              TileAnimation(
                animationType: animationType,
                delay: delay,
                from: from,
                to: to,
                tile: _tiles[tile.row][tile.col]!,
              ),
            );
          }

          // Record the cells involved in the animation
          _involvedCells.add(from);

          // At the same time, we need to check the objectives
          gameCubit.pushTileEvent(_tiles[tile.row][tile.col]?.type, 1);
        }

        // ... the delay for the next move
        delay++;

        // Compute the longest delay
        longestDelay = math.max(longestDelay, delay);

        // Let's update the _state and _types at destination.
        // Except a potential common tile (combo of more than 3 tiles)
        // would remain
        for (var tile in combo.tiles) {
          if (tile != combo.commonTile) {
            _state[tile.row][tile.col] = CellState.empty;
            _types[tile.row][tile.col] = TileType.empty;
            _tiles[tile.row][tile.col] = null;

            // Transfer the identity
            _identities[tile.row][tile.col] = -1;
          } else {
            _state[tile.row][tile.col] = CellState.occupied;
            _types[tile.row][tile.col] = combo.resultingTileType;
            (_tiles[tile.row][tile.col] as Tile).type =
                combo.resultingTileType!;
            (_tiles[tile.row][tile.col] as Tile).build();
          }
        }

      }
    }

    // If there is at least one combo,
    // wait for the combo to play before going any further
    // with the other animations
    return delay + (hasCombo ? 30 : 0);
  }

  //
  // Counts the number of "holes" (= empty cells) in a column
  // starting at a certain row
  //
  int _countNumberOfHolesAtColumStartingAtRow(int col, int row) {
    int count = 0;

    while (row > 0 &&
        _state[row][col] == CellState.empty &&
        _types[row][col] != TileType.forbidden) {
      row--;
      count++;
    }

    return count;
  }

  //
  // Routine that checks if any avalanche effect could happen.
  // This happens when a tile reaches its destination but there is
  // a "hole" in an adjacent column.
  //
  bool _processAvalanches(int col, int delay) {
    // Counter of moves caused by an avalanche effect
    int movesCounter = 0;

    final bool leftCol = (col > 0);
    final bool rightCol = (col < cols - 1);

    // Let's process all cases
    for (var avalancheTest in _avalanches[col]) {
      final int row = avalancheTest.row;

      // Count the number of "holes" on the left-hand side column
      final leftColHoles = leftCol
          ? _countNumberOfHolesAtColumStartingAtRow(col - 1, row - 1)
          : 0;

      // Count the number of "holes" on the right-hand side column
      final rightColHoles = rightCol
          ? _countNumberOfHolesAtColumStartingAtRow(col + 1, row - 1)
          : 0;
      int colOffset = 0;

      // Check if there is a hole.  If yes, the deeper wins
      if (leftColHoles + rightColHoles > 0) {
        colOffset = (leftColHoles > rightColHoles) ? -1 : (rightCol ? 1 : 0);
      }

      // If there is a hole, slide the tile to the corresponding column
      if (colOffset != 0) {
        RowCol from = RowCol(row: row, col: col);
        RowCol to = RowCol(row: row - 1, col: col + colOffset);

        // Register the avalanche animation
        _registerAnimation(
          _identities[row][col],
          delay,
          TileAnimation(
            animationType: TileAnimationType.avalanche,
            delay: delay,
            from: from,
            to: to,
            tileType: _types[row][col],
            tile: _tiles[row][col],
          ),
        );

        // Record the cells involved in the animation
        _involvedCells.addAll([from, to]);

        // Adapt _state, _types and _idenditities
        _state[row - 1][col + colOffset] = _state[row][col];
        _types[row - 1][col + colOffset] = _types[row][col];
        _tiles[row - 1][col + colOffset] = _tiles[row][col];
        _tiles[row - 1][col + colOffset]?.row = row - 1;

        _identities[row - 1][col + colOffset] = _identities[row][col];

        _state[row][col] = CellState.empty;
        _types[row][col] = TileType.empty;
        _tiles[row][col] = null;

        // As we are emptying a cell, the latter has no identity
        _identities[row][col] = -1;

        // record the move
        _lastMoves.add(RowCol(row: row - 1, col: col + colOffset));

        // Increment the counter of moves
        movesCounter++;
      }
    }

    // As we processed all avalanches related to this column, we can remove them all
    _avalanches[col].clear();

    // Inform that some
    return (movesCounter > 0);
  }

  //
  // Look for all movements (down) that need to happen in a particular column
  //
  //  Returns the longest delay, resulting from moves
  //
  int _processColumn(int col, int startDelay) {
    // Retrieve the entry row for this column
    int rowTop = _getEntryRowForColumn(col) + 1;

    // Count the number of moves
    // int countMoves = 0;

    // The number of empty cells (resulting from a move)
    int empty = 0;

    // The current delay
    int delay = startDelay;

    // The next destination row for a tile
    int dest = -1;

    // Compute the longest delay related to this column
    int longestDelay = startDelay;

    // Start scanning each row.  No need to check the bottom row since the latter will never move
    for (int row = 0; row < rowTop; row++) {
      //
      // Case were the tile is blocked or not existing
      //
      if (_state[row][col] == CellState.forbidden) {
        // This one is blocked => skip
        delay = startDelay;

        // No empty cell will be added (as an assumption)
        if (row < (rowTop - 1)) {
          empty = 0;
        }

        // We need to reset the destination row
        dest = -1;

        continue;
      }

      //
      // Case where there is no tile
      //
      if (_state[row][col] == CellState.empty) {
        // There is no tile there, so this will most become the destination if not yet taken
        if (dest == -1) {
          dest = row;
          delay = startDelay;
        }

        // In all cases, there will be a move which will lead to an empty cell at the top
        empty++;

        continue;
      }

      //
      // Case where there is a tile
      //
      if (_state[row][col] == CellState.occupied && dest != -1) {
        RowCol from = RowCol(row: row, col: col);
        RowCol to = RowCol(row: dest, col: col);

        // There will be an animation (move down)
        _registerAnimation(
          _identities[row][col],
          delay,
          TileAnimation(
            animationType: TileAnimationType.moveDown,
            delay: delay,
            from: from,
            to: to,
            tileType: _types[row][col],
            tile: _tiles[row][col],
          ),
        );

        // Record the cells involved in the animation
        _involvedCells.addAll([from, to]);

        // ... the delay for the next move
        delay++;

        // Compute the longest delay
        longestDelay = math.max(longestDelay, delay);

        // Let's update the _state and _types at destination (destination will become this _state)
        _state[dest][col] = CellState.occupied;
        _types[dest][col] = _types[row][col];
        _tiles[dest][col] = Tile.clone(_tiles[row][col]);
        _tiles[dest][col].row = dest;

        // record the move
        _lastMoves.add(to);

        // Transfer the identity
        _identities[dest][col] = _identities[row][col];

        // We need to increment the destination
        dest++;

        // ... as we moved this tile down, its former cell is now empty and has no identity
        _state[row][col] = CellState.empty;
        _types[row][col] = TileType.empty;
        _tiles[row][col] = null;
        _identities[row][col] = -1;

        // It is time to check for the avalanche effects, which will only occur at the end of the first move
        // (where the tile arrives at destination)
        if (delay == (startDelay + 1)) {
          _avalanches[col].add(
            AvalancheTest(
              delay: delay,
              row: dest,
            ),
          );
        }

        // Increment the number of moves
        // countMoves++;
      }
    }

    //
    // We now need to fill the column with new tiles (if necessary)
    // This routine is very similar to moving the tiles down
    // Except that we can only do this if the toppest cell of the column
    // if not preventing from adding new tiles
    //
    if (empty > 0) {
      int row = _getEntryRowForColumn(col);

      //
      // Only consider the case where there is an entry point
      //
      if (row != -1) {
        // Here again, it is time to check for the avalanche effects, which will only occur at the end of the first move

        // In case the destination is not yet known, determine it
        if (dest == -1) {
          do {
            dest++;
          } while (_types[dest][col] == TileType.forbidden &&
              _state[dest][col] != CellState.empty &&
              dest < rows);
        }

        TileType? previousInsertedTileType;

        // Consider each empty
        for (int i = 0; i < empty; i++) {
          TileType? newTileType;

          // Make sure not to inject a direct combo
          while (
              newTileType == null || newTileType == previousInsertedTileType) {
            newTileType =
                Tile.random(math.Random()); // Generate a new random tile type
          }
          previousInsertedTileType = newTileType;

          _state[dest][col] = CellState.occupied;
          _types[dest][col] = newTileType;
          _tiles[dest][col] = Tile(
            row: row,
            col: col,
            depth: 0,
            level: level,
            type: newTileType,
            visible: true,
          ); // We will build it later
          _tiles[dest][col].build();

          // Generate a new identity
          _identities[dest][col] = _nextIdentity++;

          // Record a new tile injection animation
          RowCol from = RowCol(row: row, col: col);
          RowCol to = RowCol(row: dest, col: col);

          _registerAnimation(
            _identities[dest][col],
            delay,
            TileAnimation(
              animationType: TileAnimationType.newTile,
              delay: delay,
              from: from,
              to: to,
              tileType: newTileType,
              tile: _tiles[dest][col],
            ),
          );
          // record the move
          _lastMoves.add(to);

          // re-align the row
          _tiles[dest][col].row = dest;

          // Record the cells involved in the animation
          _involvedCells.addAll([from, to]);

          // ... a new tile could also cause an avalanche
          if (delay == (startDelay + 1)) {
            _avalanches[col].add(
              AvalancheTest(
                delay: delay,
                row: dest,
              ),
            );
          }

          // Increment the destination
          dest++;

          // ... and the delay
          delay++;

          // Compute the longest delay
          longestDelay = math.max(longestDelay, delay);

          // Increment the number of moves
          // countMoves++;
        }
      }
    }
    return longestDelay;
  }

  //
  // Returns the row that corresponds to an entry for a new tile injection
  // Returns -1 if there is no entry
  //
  int _getEntryRowForColumn(int col) {
    int row = rows - 1;

    //
    // First, skip the not existing cells
    //
    while (_types[row][col] == TileType.forbidden) {
      row--;
    }

    //
    // Check if the top row allows new tiles injection
    // Warning, new tiles could also cause avalanches...
    //
    return (_types[row][col] == TileType.wall) ? -1 : row;
  }

  //
  // Returns the sequence of animation chains, per identity
  //
  // This is a tricky routine that needs to take several factors into consideration:
  //
  //  * the delay which is very important to have a correct sequence of animations
  //  * the identity which gives the sequence chain
  //
  // This routine returns a list of animations sequences, per identity, sorted per delay start
  //
  List<AnimationSequence> getAnimationsSequences() {
    List<AnimationSequence> sequences = <AnimationSequence>[];

    for (var identity in _animationsPerIdentityAndDelay.keys) {
      // now that we have an identity, let's put all its animations, sorted by delay
      List<TileAnimation> animations = <TileAnimation>[];

      // Let's sort the animations related to a single identity
      List<int> delays =
          _animationsPerIdentityAndDelay[identity]!.keys.toList();
      delays.sort();

      int startDelay = 0;
      int endDelay = 0;
      TileType? tileType;
      TileAnimation tileAnimation;
      Tile? tile;

      enumerate(delays).forEach((item) {
        // Remember that start and end delays as well as the type of tile
        if (item.index == 0) {
          startDelay = item.value;
          tileAnimation =
              _animationsPerIdentityAndDelay[identity]![item.value]!;
          tileType = tileAnimation.tileType;

          // If the tile does not exist, create it
          tile = tileAnimation.tile;
          if (tile == null) {
            tile = Tile(
              row: tileAnimation.from.row,
              col: tileAnimation.from.col,
              depth: 0,
              level: level,
              type: tileType,
              visible: true,
            );
            tile!.build();
            tileAnimation.tile = tile!;
          }
        }
        endDelay = math.max(endDelay, item.value);

        // add the animation
        animations.add(_animationsPerIdentityAndDelay[identity]![item.value]!);
      });

      // Record the sequence
      sequences.add(AnimationSequence(
        tileType: tileType!,
        startDelay: startDelay,
        endDelay: endDelay,
        animations: animations,
      ));
    }

    return sequences;
  }
}
