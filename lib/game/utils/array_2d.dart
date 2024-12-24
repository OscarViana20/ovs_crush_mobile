class Array2d<T> {
  late int _width;
  late int _height;
  late List<List<T?>> array;
  T? defaultValue;

  Array2d(int width, int height, {this.defaultValue}) {
    array = List<List<T?>>.filled(0, [], growable: true);
    this.width = width;
    this.height = height;
  }

  int get width => _width;
  int get height => _height;

  operator [](int x) => array[x];

  set width(int v) {
    _width = v;
    while (array.length > v) {
      array.removeLast();
    }
    while (array.length < v) {
      List<T?> newList = List<T?>.empty(growable: true);
      if (array.isNotEmpty) {
        for (int y = 0; y < array.first.length; y++) {
          newList.add(defaultValue);
        }
      }
      array.add(newList);
    }
  }

  set height(int v) {
    _height = v;
    while (array.first.length > v) {
      for (int x = 0; x < array.length; x++) {
        array[x].removeLast();
      }
    }
    while (array.first.length < v) {
      for (int x = 0; x < array.length; x++) {
        array[x].add(defaultValue);
      }
    }
  }

  Array2d<T> clone() {
    Array2d<T> newArray2d = Array2d<T>(_height, _width);
    for (int row = 0; row < _height; row++) {
      for (int col = 0; col < _width; col++) {
        newArray2d[row][col] = array[row][col];
      }
    }
    return newArray2d;
  }
}
