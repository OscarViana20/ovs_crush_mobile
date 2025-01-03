class RowCol extends Object {
  int row;
  int col;

  RowCol({
    required this.row,
    required this.col,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || hashCode == other.hashCode;

  @override
  int get hashCode => row * 1000 + col;

  @override
  String toString() {
    return '[$row][$col]';
  }
}
