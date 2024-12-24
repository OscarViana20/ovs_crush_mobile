import 'tile.dart';

class Objective extends Object {
  late TileType type;

  int count = 0;
  int initialValue = 0;
  bool completed = false;

  Objective(String string) {
    List<String> parts = string.split(";");

    type = TileType.values.firstWhere(
      (e) => e.toString().split('.')[1] == parts[1],
    );
    initialValue = int.parse(parts[0]);

    reset();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Objective && type == other.type;

  @override
  int get hashCode => type.index;

  void decrement(int value) {
    count -= value;
    if (count <= 0) {
      completed = true;
      count = 0;
    }
  }

  void reset() => count = initialValue;
}
