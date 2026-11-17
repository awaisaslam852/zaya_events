import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../domain/usecases/notifications_usecases.dart';

String unreadBadgeLabel(int count) {
  if (count <= 0) {
    return '';
  }
  if (count > 99) {
    return '99+';
  }
  return '$count';
}

class UnreadNotificationsCubit extends SafeCubit<int> {
  UnreadNotificationsCubit(this._list) : super(0);

  final ListNotifications _list;
  bool _loading = false;
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_loading) {
      return;
    }
    _loading = true;
    final result = await _list(query: const {'unreadOnly': 'true', 'pageSize': 1});
    result.fold((_) {}, (page) {
      _loaded = true;
      if (!isClosed) {
        emit(page.total);
      }
    });
    _loading = false;
  }

  void setCount(int count) {
    _loaded = true;
    if (!isClosed) {
      emit(count);
    }
  }

  void reset() {
    _loaded = false;
    emit(0);
  }
}
