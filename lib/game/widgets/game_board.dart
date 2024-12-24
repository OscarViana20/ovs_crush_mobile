import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/game_cubit.dart';
import '../models/level.dart';
import '../utils/array_2d.dart';
import '../utils/decoration_utils.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late int _cols;
  late int _rows;
  Array2d<Color>? _checker;
  Array2d<BoxDecoration>? _decorations;

  final GlobalKey _keyChecker = GlobalKey();
  final GlobalKey _keyCheckerCell = GlobalKey();

  void _initializeChecker() {
    if (_checker != null) return;

    _checker = Array2d<Color>(_rows, _cols, defaultValue: Colors.transparent);

    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        bool isEven = (row + col) % 2 == 0;
        _checker![row][col] = widget.level.grid[row][col] == 'X'
            ? Colors.transparent
            : Colors.white.withOpacity(isEven ? 0.1 : 0.3);
      }
    }
  }

  void _calculateDimensions() {
    if (_keyChecker.currentContext == null) return;

    final RenderBox boardBox =
        _keyChecker.currentContext!.findRenderObject() as RenderBox;

    final RenderBox cellBox =
        _keyCheckerCell.currentContext!.findRenderObject() as RenderBox;

    widget.level
      ..boardLeft = boardBox.localToGlobal(Offset.zero).dx
      ..boardTop = boardBox.localToGlobal(Offset.zero).dy
      ..tileWidth = cellBox.size.width
      ..tileHeight = cellBox.size.height;

    context.read<GameCubit>().notifyTilesLoaded();
  }

  _initializeBoard() {
    _rows = widget.level.numberOfRows;
    _cols = widget.level.numberOfCols;
    _decorations ??= DecorationUtils.borderDecorations(_cols, _rows, widget.level);
    _initializeChecker();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateDimensions());
  }

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final Size size = MediaQuery.of(context).size;
    final double maxDimension = math.min(size.width, size.height);
    final double maxTileWidth = math.min(
      maxDimension / cubit.kMaxTilesPerRowAndColumn,
      cubit.kMaxTilesSize,
    );

    final double width = maxTileWidth * (_cols + 1) * 1.1;
    final double height = maxTileWidth * (_rows + 1) * 1.1;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: width,
        height: height,
        color: Colors.transparent,
        child: Stack(
          children: [
            _showDecorations(),
            _showGrid(maxTileWidth),
          ],
        ),
      ),
    );
  }

  Widget _showDecorations() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1.01,
        crossAxisCount: _cols + 1,
      ),
      itemCount: (_cols + 1) * (_rows + 1),
      itemBuilder: (BuildContext context, int index) {
        final int col = index % (_cols + 1);
        final int row = (index / (_cols + 1)).floor();
        return Container(decoration: _decorations![_rows - row][col]);
      },
    );
  }

  Widget _showGrid(double width) {
    bool isFirstCell = true;
    return Padding(
      padding: EdgeInsets.all(width * 0.6),
      child: GridView.builder(
        key: _keyChecker,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols,
          childAspectRatio: 1.01,
        ),
        itemCount: _cols * _rows,
        itemBuilder: (context, int index) {
          final int col = index % _cols;
          final int row = (index / _cols).floor();
          return Container(
            color: _checker![_rows - row - 1][col],
            child: LayoutBuilder(
              builder: (context, _) {
                if (isFirstCell) {
                  isFirstCell = false;
                  return Container(key: _keyCheckerCell);
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}
