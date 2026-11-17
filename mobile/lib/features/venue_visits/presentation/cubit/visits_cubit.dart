import 'package:fpdart/fpdart.dart';
import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../domain/entities/visits_item.dart';
import '../../domain/usecases/visits_usecases.dart';
import 'visits_state.dart';

class VisitsCubit extends SafeCubit<VisitsState> {
  VisitsCubit(this._list, this._get, this._cancel, this._decide, this._approve, this._complete)
      : super(const VisitsState());

  final ListVisits _list;
  final GetVisits _get;
  final CancelVisit _cancel;
  final DecideVisit _decide;
  final ApproveVisit _approve;
  final CompleteVisit _complete;

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

  Future<String?> cancel(String id) => _mutate(_cancel(id));

  Future<String?> decide(String id, {required bool accepted}) => _mutate(_decide(id, accepted: accepted));

  Future<String?> approve(String id) => _mutate(_approve(id));

  Future<String?> complete(String id) => _mutate(_complete(id));

  Future<String?> _mutate(Future<Either<Failure, VisitsItem>> pending) async {
    final result = await pending;
    return result.fold((f) => f.message, (item) {
      _replace(item);
      AppRefresh.instance.afterVisit();
      return null;
    });
  }

  void _replace(VisitsItem item) {
    emit(
      state.copyWith(
        detail: item,
        items: [
          for (final row in state.items)
            if (row.id == item.id) item else row,
        ],
      ),
    );
  }
}
