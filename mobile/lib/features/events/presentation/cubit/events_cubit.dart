import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../domain/usecases/events_usecases.dart';
import 'events_state.dart';

class EventsCubit extends SafeCubit<EventsState> {
  EventsCubit(this._list, this._get, this._create, this._update) : super(const EventsState());

  final ListEvents _list;
  final GetEvents _get;
  final CreateEvent _create;
  final UpdateEvent _update;

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

  Future<void> loadOne(String id, {bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, error: null));
    }
    final result = await _get(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (item) => emit(state.copyWith(loading: false, detail: item)),
    );
  }

  Future<String?> create(Map<String, dynamic> body) async {
    final result = await _create(body);
    return result.fold((f) => f.message, (_) {
      AppRefresh.instance.afterEvent();
      return null;
    });
  }

  Future<String?> update(String id, Map<String, dynamic> body) async {
    final result = await _update(id, body);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      AppRefresh.instance.afterEvent();
      return null;
    });
  }
}
