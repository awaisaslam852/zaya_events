import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/events_usecases.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit(this._list, this._get, this._create, this._update) : super(const EventsState());

  final ListEvents _list;
  final GetEvents _get;
  final CreateEvent _create;
  final UpdateEvent _update;

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

  Future<String?> create(Map<String, dynamic> body) async {
    final result = await _create(body);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> update(String id, Map<String, dynamic> body) async {
    final result = await _update(id, body);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      return null;
    });
  }
}
