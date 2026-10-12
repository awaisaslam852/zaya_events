import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../calls/presentation/bloc/call_bloc.dart';
import '../../../calls/presentation/bloc/call_event.dart';
import '../cubit/chat_cubit.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({super.key, required this.id});
  final String id;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myId = context.read<AuthBloc>().state.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..openThread(widget.id),
      child: BlocListener<ChatCubit, ChatState>(
        listenWhen: (prev, next) => next.error != null && next.error != prev.error,
        listener: (context, state) {
          final error = state.error;
          if (error != null && error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.canvas,
          appBar: AppBar(
            title: Text(l10n.chat),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    tooltip: l10n.voiceCall,
                    icon: const Icon(Icons.call_outlined),
                    onPressed: () {
                      final peer = context.read<ChatCubit>().peerOf(myId);
                      if (peer == null || peer.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
                        return;
                      }
                      context.read<CallBloc>().add(CallEvent.outgoing(calleeId: peer));
                      context.push('/calls/outgoing');
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.loading && state.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        final mine = msg['senderId']?.toString() == myId;
                        return Align(
                          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
                            decoration: BoxDecoration(
                              color: mine ? AppTheme.navy : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: mine ? null : Border.all(color: const Color(0xFFE6EEF7)),
                            ),
                            child: Text(
                              msg['body']?.toString() ?? '',
                              style: TextStyle(color: mine ? Colors.white : const Color(0xFF1A2B49), height: 1.35),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Material(
                color: Colors.white,
                elevation: 8,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: l10n.typeMessage,
                              filled: true,
                              fillColor: AppTheme.canvas,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: AppTheme.yellow, foregroundColor: const Color(0xFF1A1A1A)),
                          icon: _sending
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send_rounded),
                          onPressed: _sending
                              ? null
                              : () async {
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) {
                                    return;
                                  }
                                  setState(() => _sending = true);
                                  final error = await context.read<ChatCubit>().send(widget.id, text);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  setState(() => _sending = false);
                                  if (error == null) {
                                    _controller.clear();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
