import 'package:get_it/get_it.dart';
import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../domain/entities/notifications_item.dart';
import '../../domain/usecases/notifications_usecases.dart';
import 'notifications_state.dart';
import 'unread_notifications_cubit.dart';

class NotificationsCubit extends SafeCubit<NotificationsState> {
  NotificationsCubit(this._list, this._get, this._markRead, this._markAllRead) : super(const NotificationsState());

  final ListNotifications _list;
  final GetNotifications _get;
  final MarkNotificationRead _markRead;
  final MarkAllNotificationsRead _markAllRead;

  Future<void> load({Map<String, dynamic>? query, bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, error: null));
    }
    final result = await _list(query: query);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, error: null, items: page.items)),
    );
  }

  Future<void> loadOne(String id) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _get(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (item) => emit(state.copyWith(loading: false, detail: item)),
    );
  }

  Future<void> markRead(String id) async {
    final stamped = DateTime.now().toUtc().toIso8601String();
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            item.id == id ? NotificationsItem({...item.raw, 'readAt': stamped}) : item,
        ],
      ),
    );
    await _markRead(id);
    _refreshUnread();
  }

  Future<void> markAllRead() async {
    final stamped = DateTime.now().toUtc().toIso8601String();
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            NotificationsItem({...item.raw, 'readAt': item.raw['readAt'] ?? stamped}),
        ],
      ),
    );
    await _markAllRead();
    if (GetIt.I.isRegistered<UnreadNotificationsCubit>()) {
      GetIt.I<UnreadNotificationsCubit>().setCount(0);
    }
  }

  void _refreshUnread() {
    if (GetIt.I.isRegistered<UnreadNotificationsCubit>()) {
      GetIt.I<UnreadNotificationsCubit>().refresh();
    }
  }
}
