import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/flights_item.dart';

part 'flights_state.freezed.dart';

@freezed
abstract class FlightsState with _$FlightsState {
  const factory FlightsState({
    @Default(false) bool loading,
    String? error,
    @Default(<FlightsItem>[]) List<FlightsItem> items,
    FlightsItem? detail,
  }) = _FlightsState;
}
