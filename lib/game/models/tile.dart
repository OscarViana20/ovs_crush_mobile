import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/decoration_utils.dart';
import 'level.dart';

enum TileType {
  forbidden,
  empty,
  red,
  green,
  blue,
  orange,
  purple,
  yellow,
  wall,
  bomb,
  flare,
  blue_v,
  blue_h,
  red_v,
  red_h,
  green_v,
  green_h,
  orange_v,
  orange_h,
  purple_v,
  purple_h,
  yellow_v,
  yellow_h,
  wrapped,
  fireball,
  bomb_v,
  bomb_h,
  last,
}

class Tile extends Object {
  Tile({
    this.type,
    this.level,
    this.row = 0,
    this.col = 0,
    this.depth = 0,
    this.visible = true,
  });

  int row;
  int col;
  int depth;
  bool visible;
  Level? level;
  TileType? type;

  double? x;
  double? y;
  Widget? _widget;

  @override
  int get hashCode => row * level!.numberOfRows + col;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other.hashCode == hashCode;
  }

  bool get canMove => depth == 0 && canBePlayed(type!);

  Widget get widget => getWidgetSized(level!.tileWidth, level!.tileHeight);

  factory Tile.clone(Tile otherTile) {
    Tile newTile = Tile(
      type: otherTile.type,
      level: otherTile.level,
      row: otherTile.row,
      col: otherTile.col,
      depth: otherTile.depth,
      visible: otherTile.visible,
    );
    newTile.x = otherTile.x;
    newTile.y = otherTile.y;
    newTile._widget = otherTile._widget;
    return newTile;
  }

  void build({bool computePosition = true}) {
    if (depth > 0 && type != TileType.wall) {
      _widget = Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Transform.scale(
              scale: 0.8,
              child: DecorationUtils.tileDecoration(type),
            ),
          ),
          DecorationUtils.tileDecoration(type, 'deco/ice_02.png'),
        ],
      );
    } else if (type == TileType.empty) {
      _widget = Container();
    } else {
      _widget = DecorationUtils.tileDecoration(type);
    }

    if (computePosition) {
      setPosition();
    }
  }

  void setPosition() {
    double bottom =
        level!.boardTop + (level!.numberOfRows - 1) * level!.tileHeight;
    x = level!.boardLeft + col * level!.tileWidth;
    y = bottom - row * level!.tileHeight;
  }

  Widget getWidgetSized(double width, double height) =>
      SizedBox(width: width, height: height, child: _widget);

  static TileType random(math.Random rnd) {
    int minValue = TileType.red.index;
    int maxValue = TileType.yellow.index;
    int value = rnd.nextInt(maxValue - minValue) + minValue;
    return TileType.values[value];
  }

  static bool isNormal(TileType type) {
    int index = type.index;
    return (index >= TileType.red.index && index <= TileType.yellow.index);
  }

  static bool isBomb(TileType type) {
    int index = type.index;
    return (index >= TileType.bomb.index && index <= TileType.fireball.index);
  }

  static bool canBePlayed(TileType type) {
    return type != TileType.wall && type != TileType.forbidden;
  }

  static TileType normalizeBombType(TileType bombType) {
    switch (bombType) {
      case TileType.blue_v:
      case TileType.red_v:
      case TileType.green_v:
      case TileType.orange_v:
      case TileType.purple_v:
      case TileType.yellow_v:
        return TileType.bomb;

      case TileType.blue_h:
      case TileType.red_h:
      case TileType.green_h:
      case TileType.orange_h:
      case TileType.purple_h:
      case TileType.yellow_h:
        return TileType.bomb_h;

      default:
        return bombType;
    }
  }

  Tile cloneForAnimation() {
    Tile tile = Tile(level: level, type: type, row: row, col: col);
    tile.build();
    return tile;
  }

  void swapRowColWith(Tile destTile) {
    int tft = destTile.row;
    destTile.row = row;
    row = tft;

    tft = destTile.col;
    destTile.col = col;
    col = tft;
  }
}
