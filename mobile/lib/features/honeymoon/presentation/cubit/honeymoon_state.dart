import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/honeymoon_item.dart';

part 'honeymoon_state.freezed.dart';

@freezed
abstract class HoneymoonState with _$HoneymoonState {
  const factory HoneymoonState({
    @Default(false) bool loading,
    String? error,
    @Default(<HoneymoonItem>[]) List<HoneymoonItem> items,
    HoneymoonItem? detail,
  }) = _HoneymoonState;
}
