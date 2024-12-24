import 'package:quiver/iterables.dart';

import '../utils/array_2d.dart';
import 'objetive.dart';

class Level extends Object {
  final int _index;
  final int _rows;
  final int _cols;
  final int _maxMoves;

  late Array2d grid;
  late List<Objective> _objectives;

  int _movesLeft = 0;
  double tileWidth = 0.0;
  double tileHeight = 0.0;
  double boardLeft = 0.0;
  double boardTop = 0.0;

  int get index => _index;
  int get numberOfRows => _rows;
  int get numberOfCols => _cols;
  int get maxMoves => _maxMoves;
  int get movesLeft => _movesLeft;
  List<Objective> get objectives => List.unmodifiable(_objectives);

  Level.fromJson(Map<String, dynamic> json)
      : _index = json["level"],
        _rows = json["rows"],
        _cols = json["cols"],
        _maxMoves = json["moves"] {
    grid = Array2d(_rows, _cols);

    enumerate((json["grid"] as List).reversed).forEach((row) {
      enumerate(row.value.split(',')).forEach((cell) {
        grid[row.index][cell.index] = cell.value;
      });
    });

    _objectives = (json["objective"] as List).map((item) {
      return Objective(item);
    }).toList();

    resetObjectives();
  }

  void resetObjectives() {
    for (var objective in _objectives) {
      objective.reset();
    }
    _movesLeft = _maxMoves;
  }

  int decrementMove() {
    return (--_movesLeft).clamp(0, _maxMoves);
  }
}
