import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/call_entity.dart';

part 'call_state.freezed.dart';

@freezed
abstract class CallState with _$CallState {
  const factory CallState({
    CallEntity? incoming,
    CallEntity? outgoing,
    CallEntity? active,
    CallToken? token,
    @Default([]) List<CallEntity> history,
    @Default(false) bool loading,
    String? error,
  }) = _CallState;
}
