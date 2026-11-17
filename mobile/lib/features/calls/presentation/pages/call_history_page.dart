import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<CallBloc>().add(const CallEvent.loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(showBack: true, eyebrow: l10n.support, title: l10n.callHistory, subtitle: l10n.callsSubtitle),
          Expanded(
            child: BlocBuilder<CallBloc, CallState>(
              builder: (context, state) {
                return AsyncBody(
                  loading: state.loading && state.history.isEmpty,
                  error: state.error,
                  empty: state.history.isEmpty,
                  emptyIcon: Icons.call_outlined,
                  emptyTitle: l10n.noCallsYet,
                  emptyMessage: l10n.callsSubtitle,
                  onRetry: () => context.read<CallBloc>().add(const CallEvent.loadHistory()),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: state.history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final call = state.history[index];
                      final time = relativeTimeLabel(l10n, call.raw['createdAt'] ?? call.raw['startedAt']);
                      return Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.line),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.wash,
                              child: Icon(
                                call.status.toUpperCase().contains('MISS') || call.status.toUpperCase().contains('REJECT')
                                    ? Icons.call_missed_outgoing
                                    : Icons.call_outlined,
                                color: AppTheme.navy,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    call.status,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [if (time.isNotEmpty) time, call.channelName ?? call.id].join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(label: call.status),
                          ],
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
    );
  }
}
