import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cars_item.dart';

part 'cars_state.freezed.dart';

@freezed
abstract class CarsState with _$CarsState {
  const factory CarsState({
    @Default(false) bool loading,
    String? error,
    @Default(<CarsItem>[]) List<CarsItem> items,
    CarsItem? detail,
  }) = _CarsState;
}
