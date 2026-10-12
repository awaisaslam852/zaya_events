import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/hotels_item.dart';

part 'hotels_state.freezed.dart';

@freezed
abstract class HotelsState with _$HotelsState {
  const factory HotelsState({
    @Default(false) bool loading,
    String? error,
    @Default(<HotelsItem>[]) List<HotelsItem> items,
    HotelsItem? detail,
  }) = _HotelsState;
}
