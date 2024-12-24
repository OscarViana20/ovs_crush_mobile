import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/objetive_event.dart';
import '../models/tile.dart';

class ObjectiveCubit extends Cubit<Map<TileType, int>> {
  ObjectiveCubit() : super({});
 
  void handleObjectiveEvent(ObjectiveEvent event) {
    emit({
      ...state,
      event.type: event.remaining,
    });
  }
}