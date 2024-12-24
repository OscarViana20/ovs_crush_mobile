import 'dart:collection';
import 'dart:math' as math;

import '../cubit/game_cubit.dart';
import '../models/chain.dart';
import '../models/combo.dart';
import '../models/level.dart';
import '../models/row_col.dart';
import '../models/swap.dart';
import '../models/swap_move.dart';
import '../models/tile.dart';
import '../utils/array_2d.dart';

class GameController {
  late Level level;
  late math.Random _rnd;
  late Array2d<Tile> _grid;
  late HashMap<int, Swap> _swaps;

  GameController({
    required this.level,
  }) {
    _grid = Array2d<Tile>(
      level.numberOfRows,
      level.numberOfCols,
      defaultValue: Tile(type: TileType.empty),
    );

    _rnd = math.Random();

    _swaps = HashMap<int, Swap>();
  }

  Array2d<Tile> get grid => _grid;

  void shuffle() {
    bool isFirst = true;
    var clone = _grid.clone();
    do {
      if (!isFirst) {
        _grid = clone.clone();
      }
      isFirst = false;
      _fillEmptyCells();
      identifySwaps();
    } while (_swaps.isEmpty);
    _buildGrid();
  }

  void _fillEmptyCells() {
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        if (_grid[row][col].type != TileType.empty) continue;
        _grid[row][col] = _createTile(row, col);
      }
    }
  }

  Tile _createTile(int row, int col) {
    late Tile tile;
    TileType type;
    switch (level.grid[row][col]) {
      case '1':
      case '2':
        do {
          type = Tile.random(_rnd);
        } while (_isMatchingTile(row, col, type));
        tile = Tile(
          row: row,
          col: col,
          type: type,
          level: level,
          depth: (level.grid[row][col] == '2') ? 1 : 0,
        );
        break;
      case 'X':
        tile = Tile(
          row: row,
          col: col,
          type: TileType.forbidden,
          level: level,
          depth: 1,
        );
        break;
      case 'W':
        tile = Tile(
            row: row, col: col, type: TileType.wall, level: level, depth: 1);
        break;
      default:
        tile = Tile(row: row, col: col, type: TileType.empty, level: level);
    }
    return tile;
  }

  bool _isMatchingTile(int row, int col, TileType type) {
    return (col > 1 &&
            _grid[row][col - 1].type == type &&
            _grid[row][col - 2].type == type) ||
        (row > 1 &&
            _grid[row - 1][col].type == type &&
            _grid[row - 2][col].type == type);
  }

  void identifySwaps() {
    _swaps.clear();
    int totalRows = _grid.height;
    int totalCols = _grid.width;
    for (int row = 0; row < totalRows; row++) {
      for (int col = 0; col < totalCols; col++) {
        Tile fromTile = Tile.clone(_grid[row][col]);
        if (Tile.isNormal(fromTile.type!) || Tile.isBomb(fromTile.type!)) {
          _processTileSwaps(row, col, fromTile, totalRows, totalCols);
        }
      }
    }
  }

  void _processTileSwaps(
    int row,
    int col,
    Tile fromTile,
    int totalRows,
    int totalCols,
  ) {
    for (SwapMove move in moves) {
      int destRow = row + move.row;
      int destCol = col + move.col;
      bool valid = destRow >= 0 &&
          destRow < totalRows &&
          destCol >= 0 &&
          destCol < totalCols;

      if (!valid) continue;

      Tile toTile = Tile.clone(_grid[destRow][destCol]);
      if (toTile.type != TileType.forbidden) {
        _evaluateSwap(row, col, fromTile, destRow, destCol, toTile);
      }
    }
  }

  void _evaluateSwap(
    int row,
    int col,
    Tile fromTile,
    int destRow,
    int destCol,
    Tile toTile,
  ) {
    if (Tile.isBomb(fromTile.type!) ||
        Tile.isBomb(toTile.type!) ||
        toTile.type == TileType.empty ||
        toTile.type != fromTile.type) {
      _attemptSwap(row, col, fromTile, destRow, destCol, toTile);
    }
  }

  void _attemptSwap(
    int row,
    int col,
    Tile fromTile,
    int destRow,
    int destCol,
    Tile toTile,
  ) {
    _grid[destRow][destCol] =
        Tile(row: row, col: col, type: fromTile.type, level: level);

    _grid[row][col] =
        Tile(row: destRow, col: destCol, type: toTile.type, level: level);

    if (_checkChains(destRow, destCol) || _checkChains(row, col)) {
      _addSwaps(fromTile, toTile);
    }

    _grid[destRow][destCol] = toTile;
    _grid[row][col] = fromTile;
  }

  bool _checkChains(int row, int col) {
    return ChainHelper.checkHorizontalChain(row, col, _grid) != null ||
        ChainHelper.checkVerticalChain(row, col, _grid) != null;
  }

  void _buildGrid() {
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        if (_grid[row][col].type != TileType.forbidden) {
          _grid[row][col].build();
        }
      }
    }
  }

  void _addSwaps(Tile fromTile, Tile toTile) {
    Swap newSwap = Swap(from: fromTile, to: toTile);
    _swaps.putIfAbsent(newSwap.hashCode, () => newSwap);

    newSwap = Swap(from: toTile, to: fromTile);
    _swaps.putIfAbsent(newSwap.hashCode, () => newSwap);
  }

  bool swapContains(Tile source, Tile destination) {
    Swap testSwap = Swap(from: source, to: destination);
    return _swaps.keys.contains(testSwap.hashCode);
  }

  void swapTiles(Tile source, Tile destination) {
    RowCol sourceRowCol = RowCol(row: source.row, col: source.col);
    RowCol destRowCol = RowCol(row: destination.row, col: destination.col);

    source.swapRowColWith(destination);

    Tile tft = grid[sourceRowCol.row][sourceRowCol.col];
    grid[sourceRowCol.row][sourceRowCol.col] =
        grid[destRowCol.row][destRowCol.col];
    grid[destRowCol.row][destRowCol.col] = tft;
  }

  Combo getCombo(int row, int col) {
    Chain? verticalChain = ChainHelper.checkVerticalChain(row, col, _grid);
    Chain? horizontalChain = ChainHelper.checkHorizontalChain(row, col, _grid);
    return Combo(horizontalChain, verticalChain, row, col);
  }

  void resolveCombo(Combo combo, GameCubit gameCubit) {
    // We now need to remove all the Tiles from the grid and change the type if necessary
    for (var tile in combo.tiles) {
      if (tile != combo.commonTile) {
        // Decrement the depth
        if (--grid[tile.row][tile.col].depth < 0) {
          // Check for objectives
          gameCubit.pushTileEvent(grid[tile.row][tile.col].type, 1);

          // If the depth is lower than 0, this means that we can remove the tile
          grid[tile.row][tile.col].type = TileType.empty;
        }
        // We need to rebuild the Widget
        grid[tile.row][tile.col].build();
      } else {
        grid[tile.row][tile.col].row = combo.commonTile!.row;
        grid[tile.row][tile.col].col = combo.commonTile!.col;
        grid[tile.row][tile.col].type = combo.resultingTileType;
        grid[tile.row][tile.col].visible = true;
        grid[tile.row][tile.col].build();

        // We need to notify about the creation of a new tile
        gameCubit.pushTileEvent(combo.resultingTileType!, 1);
      }
    }
  }

  void refreshGridAfterAnimations(
    Array2d<TileType> tileTypes,
    Set<RowCol> involvedCells,
  ) {
    for (var rowCol in involvedCells) {
      _grid[rowCol.row][rowCol.col].row = rowCol.row;
      _grid[rowCol.row][rowCol.col].col = rowCol.col;
      _grid[rowCol.row][rowCol.col].type = tileTypes[rowCol.row][rowCol.col];
      _grid[rowCol.row][rowCol.col].visible = true;
      _grid[rowCol.row][rowCol.col].depth = 0;
      _grid[rowCol.row][rowCol.col].build();
    }
  }

  void proceedWithExplosion(
    Tile tileExplosion,
    GameCubit gameCubit, {
    bool skipThis = false,
  }) {
    List<Tile> subExplosions = [];
    List<SwapMove>? swaps = explosions[Tile.normalizeBombType(
      tileExplosion.type!,
    )];

    // All the tiles in that area will disappear
    swaps?.forEach((SwapMove move) {
      int row = tileExplosion.row + move.row;
      int col = tileExplosion.col + move.col;

      // Test if the cell is valid
      if (row > -1 &&
          row < level.numberOfRows &&
          col > -1 &&
          col < level.numberOfCols) {
        // And also if we may explode the tile
        if (level.grid[row][col] == '1') {
          Tile? tile = _grid[row][col];

          if (tile != null &&
              Tile.isBomb(tile.type!) &&
              !skipThis &&
              tile.row != tileExplosion.row &&
              tile.col != tileExplosion.col) {
            // Another bomb must explode
            subExplosions.add(tile);
          } else {
            // Notify that we removed some tiles
            gameCubit.pushTileEvent(tile!.type!, 1);

            // Empty the cell
            if (tile.depth == 0) {
              tile.type = TileType.empty;
            } else {
              // This tile was frozen, so unfreeze this one level down
              tile.depth--;
            }
            tile.build();
          }
        }
      }
    });

    // Proceed with chained explosions
    for (var tile in subExplosions) {
      proceedWithExplosion(tile, gameCubit, skipThis: true);
    }
  }

  bool stillMovesToPlay() {
    if (_swaps.isEmpty) {
      for (int row = 0; row < level.numberOfRows; row++) {
        for (int col = 0; col < level.numberOfCols; col++) {
          Tile tile = _grid[row][col];
          if (level.grid[row][col] == '1' && Tile.isBomb(tile.type!)) {
            return true;
          }
        }
      }
      return false;
    }
    return true;
  }

  void reshuffling() {
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        Tile tile = _grid[row][col];
        if (Tile.isNormal(tile.type!)) {
          _grid[row][col].type = TileType.empty;
        }
      }
    }
    shuffle();
  }
}
