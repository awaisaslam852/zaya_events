import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/visits_item.dart';

part 'visits_state.freezed.dart';

@freezed
abstract class VisitsState with _$VisitsState {
  const factory VisitsState({
    @Default(false) bool loading,
    String? error,
    @Default(<VisitsItem>[]) List<VisitsItem> items,
    VisitsItem? detail,
  }) = _VisitsState;
}
