import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../domain/entities/call_entity.dart';
import '../../domain/usecases/call_usecases.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc({
    required this.initiate,
    required this.accept,
    required this.reject,
    required this.end,
    required this.token,
    required this.history,
    required this.sockets,
  }) : super(const CallState()) {
    sockets.onConnected.add(() => add(const CallEvent.started()));
    on<CallEvent>((event, emit) async {
      await event.map(
        started: (_) => _onStarted(emit),
        incomingFromPush: (e) async {
          final id = e.payload['callId']?.toString() ?? e.payload['id']?.toString() ?? '';
          if (id.isEmpty) return;
          emit(state.copyWith(incoming: CallEntity(id: id, status: 'RINGING', raw: e.payload)));
        },
        outgoing: (e) => _outgoing(e.calleeId, e.bookingId, emit),
        accept: (e) => _accept(e.id, emit),
        reject: (e) => _reject(e.id, emit),
        end: (e) => _end(e.id, emit),
        loadHistory: (_) => _history(emit),
      );
    });
  }

  final InitiateCall initiate;
  final AcceptCall accept;
  final RejectCall reject;
  final EndCall end;
  final GetCallToken token;
  final ListCallHistory history;
  final SocketService sockets;

  Future<void> _onStarted(Emitter<CallState> emit) async {
    sockets.calls?.on('incoming_call', (data) {
      if (data is Map) {
        add(CallEvent.incomingFromPush(Map<String, dynamic>.from(data)));
      }
    });
    sockets.calls?.on('call_ended', (_) {
      add(const CallEvent.loadHistory());
    });
  }

  Future<bool> _perms() async {
    final statuses = await [Permission.microphone, Permission.camera].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> _outgoing(String calleeId, String? bookingId, Emitter<CallState> emit) async {
    if (!await _perms()) {
      emit(state.copyWith(loading: false, error: 'Microphone permission is required for a voice call'));
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    final result = await initiate(calleeId: calleeId, bookingId: bookingId);
    await result.fold(
      (f) async => emit(state.copyWith(loading: false, error: f.message)),
      (call) async => emit(state.copyWith(loading: false, outgoing: call)),
    );
  }

  Future<void> _accept(String id, Emitter<CallState> emit) async {
    if (!await _perms()) {
      emit(state.copyWith(error: 'permissions'));
      return;
    }
    final accepted = await accept(id);
    await accepted.fold(
      (f) async => emit(state.copyWith(error: f.message)),
      (call) async {
        final tok = await token(id);
        tok.fold(
          (f) => emit(state.copyWith(error: f.message, incoming: null)),
          (t) => emit(state.copyWith(incoming: null, active: call, token: t)),
        );
      },
    );
  }

  Future<void> _reject(String id, Emitter<CallState> emit) async {
    await reject(id);
    emit(state.copyWith(incoming: null, outgoing: null, active: null, token: null));
  }

  Future<void> _end(String id, Emitter<CallState> emit) async {
    await end(id);
    emit(state.copyWith(incoming: null, outgoing: null, active: null, token: null));
  }

  Future<void> _history(Emitter<CallState> emit) async {
    final result = await history();
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (page) => emit(state.copyWith(history: page.items)),
    );
  }
}
