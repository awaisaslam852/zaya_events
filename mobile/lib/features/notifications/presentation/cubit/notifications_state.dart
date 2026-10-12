import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notifications_item.dart';

part 'notifications_state.freezed.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(false) bool loading,
    String? error,
    @Default(<NotificationsItem>[]) List<NotificationsItem> items,
    NotificationsItem? detail,
  }) = _NotificationsState;
}
