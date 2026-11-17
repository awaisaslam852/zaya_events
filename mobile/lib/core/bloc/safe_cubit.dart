import 'package:flutter_bloc/flutter_bloc.dart';

/// Drops [emit] after [close] so a page can be left while an API call is
/// still running (login redirect, tab change) without crashing the app.
class SafeCubit<T> extends Cubit<T> {
  SafeCubit(super.initialState);

  @override
  void emit(T state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }
}
