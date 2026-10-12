import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/events_item.dart';

part 'events_state.freezed.dart';

@freezed
abstract class EventsState with _$EventsState {
  const factory EventsState({
    @Default(false) bool loading,
    String? error,
    @Default(<EventsItem>[]) List<EventsItem> items,
    EventsItem? detail,
  }) = _EventsState;
}
