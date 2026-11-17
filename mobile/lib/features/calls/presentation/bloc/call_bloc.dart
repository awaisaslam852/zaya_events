import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/pending_incoming_call.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../call_audio.dart';
import '../../call_payload.dart';
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
        started: (_) async => _onStarted(),
        incomingFromPush: (e) async {
          final call = CallEntity.fromIncoming(e.payload);
          if (call.id.isEmpty) {
            return;
          }
          emit(state.copyWith(incoming: call));
        },
        outgoing: (e) => _outgoing(e.calleeId, e.bookingId, emit),
        accept: (e) => _accept(e.id, emit),
        reject: (e) => _reject(e.id, emit),
        end: (e) => _end(e.id, emit),
        peerAccepted: (e) => _joinAsCaller(e.id, emit),
        cleared: (_) async {
          await dismissIncomingCallNotification(state.incoming?.id ?? state.active?.id);
          emit(state.copyWith(incoming: null, outgoing: null, active: null, token: null));
        },
        loadHistory: (_) => _history(emit),
      );
    });
    if (sockets.callsConnected) {
      add(const CallEvent.started());
    }
  }

  final InitiateCall initiate;
  final AcceptCall accept;
  final RejectCall reject;
  final EndCall end;
  final GetCallToken token;
  final ListCallHistory history;
  final SocketService sockets;

  void _onIncoming(dynamic data) {
    final map = callPayloadMap(data);
    if (map == null) {
      return;
    }
    add(CallEvent.incomingFromPush(map));
  }

  void _onAccepted(dynamic data) {
    final map = callPayloadMap(data) ?? <String, dynamic>{};
    final id = map['callId']?.toString() ?? map['id']?.toString() ?? '';
    if (id.isEmpty) {
      return;
    }
    add(CallEvent.peerAccepted(id));
  }

  void _onStarted() {
    final socket = sockets.calls;
    if (socket == null) {
      return;
    }
    socket.off('call:incoming');
    socket.off('incoming_call');
    socket.off('call:accepted');
    socket.off('call:ended');
    socket.off('call_ended');
    socket.off('call:rejected');
    socket.off('call:missed');
    socket.on('call:incoming', _onIncoming);
    socket.on('incoming_call', _onIncoming);
    socket.on('call:accepted', _onAccepted);
    socket.on('call:ended', (_) => add(const CallEvent.cleared()));
    socket.on('call_ended', (_) => add(const CallEvent.cleared()));
    socket.on('call:rejected', (_) => add(const CallEvent.cleared()));
    socket.on('call:missed', (_) => add(const CallEvent.cleared()));
  }

  Future<void> _joinAsCaller(String id, Emitter<CallState> emit) async {
    if (state.token != null && state.active?.id == id) {
      return;
    }
    final tok = await token(id);
    await tok.fold(
      (f) async => emit(state.copyWith(error: f.message)),
      (t) async {
        final call = state.outgoing ?? state.active ?? CallEntity(id: id, status: 'ACCEPTED', raw: {'id': id});
        emit(state.copyWith(outgoing: null, incoming: null, active: call, token: t, error: null));
      },
    );
  }

  Future<bool> _perms() async {
    final status = await ensureCallAudioPermission();
    return status == CallAudioPermission.granted;
  }

  Future<void> _outgoing(String calleeId, String? bookingId, Emitter<CallState> emit) async {
    if (!await _perms()) {
      emit(
        state.copyWith(
          loading: false,
          error: micPermissionError,
          outgoing: CallEntity(
            id: 'pending',
            status: 'PERMISSION',
            calleeId: calleeId,
            raw: {'calleeId': calleeId, if (bookingId != null) 'bookingId': bookingId},
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    final result = await initiate(calleeId: calleeId, bookingId: bookingId);
    await result.fold(
      (f) async => emit(state.copyWith(loading: false, error: f.message)),
      (call) async => emit(state.copyWith(loading: false, outgoing: call, error: null)),
    );
  }

  Future<void> _accept(String id, Emitter<CallState> emit) async {
    if (!await _perms()) {
      emit(state.copyWith(error: micPermissionError));
      return;
    }
    final accepted = await accept(id);
    await accepted.fold(
      (f) async => emit(state.copyWith(error: f.message)),
      (call) async {
        await dismissIncomingCallNotification(id);
        final tok = await token(id);
        tok.fold(
          (f) => emit(state.copyWith(error: f.message, incoming: null)),
          (t) => emit(state.copyWith(incoming: null, active: call, token: t)),
        );
      },
    );
  }

  Future<void> _reject(String id, Emitter<CallState> emit) async {
    await dismissIncomingCallNotification(id);
    await reject(id);
    emit(state.copyWith(incoming: null, outgoing: null, active: null, token: null));
  }

  Future<void> _end(String id, Emitter<CallState> emit) async {
    await dismissIncomingCallNotification(id);
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
