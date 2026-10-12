import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/chat_usecases.dart';
import '../cubit/chat_cubit.dart';

class ChatInboxPage extends StatelessWidget {
  const ChatInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myId = context.read<AuthBloc>().state.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..loadInbox(),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(
              eyebrow: l10n.chat,
              title: 'Messages',
              subtitle: 'Keep the conversation going with your bookings.',
              trailing: FilledButton.icon(
                onPressed: () async {
                  final result = await sl<StartSupport>()();
                  if (!context.mounted) {
                    return;
                  }
                  result.fold(
                    (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                    (row) {
                      final id = row['id']?.toString();
                      if (id != null) {
                        context.push('/chat/$id');
                      }
                    },
                  );
                },
                icon: const Icon(Icons.support_agent, size: 18),
                label: Text(l10n.contactSupport),
              ),
            ),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.conversations.isEmpty,
                    emptyIcon: Icons.chat_bubble_outline,
                    emptyTitle: l10n.noConversations,
                    emptyMessage: 'Enquiries and vendor replies will show up here.',
                    onRetry: () => context.read<ChatCubit>().loadInbox(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = state.conversations[index];
                        final name = _peerName(item, myId);
                        final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
                        return Card(
                          child: ListTile(
                            onTap: () => context.push('/chat/${item['id']}'),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.navy,
                              child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            title: Text(name.isEmpty ? 'Conversation' : name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text(
                              item['lastMessageAt']?.toString().split('T').first ?? 'Tap to open',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _peerName(Map<String, dynamic> item, String myId) {
    final a = item['participantA'];
    final b = item['participantB'];
    final peer = a is Map && a['id']?.toString() == myId ? b : a;
    if (peer is Map) {
      return '${peer['firstName'] ?? ''} ${peer['lastName'] ?? ''}'.trim();
    }
    return '';
  }
}
