import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/visits_usecases.dart';
import 'visits_state.dart';

class VisitsCubit extends Cubit<VisitsState> {
  VisitsCubit(this._list, this._get, this._cancel, this._decide) : super(const VisitsState());

  final ListVisits _list;
  final GetVisits _get;
  final CancelVisit _cancel;
  final DecideVisit _decide;

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

  Future<String?> cancel(String id) async {
    final result = await _cancel(id);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      return null;
    });
  }

  Future<String?> decide(String id, {required bool accepted}) async {
    final result = await _decide(id, accepted: accepted);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      return null;
    });
  }
}
