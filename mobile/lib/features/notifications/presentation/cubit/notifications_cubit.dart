import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notifications_usecases.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._list, this._get) : super(const NotificationsState());

  final ListNotifications _list;
  final GetNotifications _get;

  Future<void> load({Map<String, dynamic>? query}) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _list(query: query);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, items: page.items)),
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
}
