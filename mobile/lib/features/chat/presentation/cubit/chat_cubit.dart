import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../domain/chat_usecases.dart';

part 'chat_cubit.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(false) bool loading,
    String? error,
    @Default([]) List<Map<String, dynamic>> conversations,
    @Default([]) List<Map<String, dynamic>> messages,
  }) = _ChatState;
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._list, this._messages, this._send, this._get, this._sockets) : super(const ChatState());

  final ListConversations _list;
  final ListMessages _messages;
  final SendMessage _send;
  final GetConversation _get;
  final SocketService _sockets;

  String? participantAId;
  String? participantBId;
  String? _conversationId;

  String? peerOf(String myId) {
    if (participantAId == myId) {
      return participantBId;
    }
    if (participantBId == myId) {
      return participantAId;
    }
    return participantAId == myId ? participantBId : participantAId ?? participantBId;
  }

  void _append(dynamic data) {
    if (data is! Map) {
      return;
    }
    final map = Map<String, dynamic>.from(data);
    final convo = map['conversationId']?.toString();
    if (_conversationId != null && convo != null && convo != _conversationId) {
      return;
    }
    final id = map['id']?.toString();
    if (id != null && state.messages.any((m) => m['id']?.toString() == id)) {
      return;
    }
    emit(state.copyWith(messages: [...state.messages, map], error: null));
  }

  Future<void> loadInbox() async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _list();
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, conversations: page.items)),
    );
  }

  Future<void> openThread(String id) async {
    _conversationId = id;
    emit(state.copyWith(loading: true, error: null));
    _sockets.chat?.off('message');
    _sockets.chat?.off('message:new');
    _sockets.chat?.emit('join', id);
    final convo = await _get(id);
    convo.fold((_) {}, (row) {
      participantAId = row['participantAId']?.toString();
      participantBId = row['participantBId']?.toString();
    });
    final result = await _messages(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, messages: page.items.reversed.toList())),
    );
    _sockets.chat?.on('message:new', _append);
    _sockets.chat?.on('message', _append);
  }

  Future<String?> send(String id, String body) async {
    final result = await _send(id, body);
    return result.fold(
      (f) {
        emit(state.copyWith(error: f.message));
        return f.message;
      },
      (msg) {
        _append(msg);
        return null;
      },
    );
  }

  @override
  Future<void> close() {
    _sockets.chat?.off('message');
    _sockets.chat?.off('message:new');
    return super.close();
  }
}
