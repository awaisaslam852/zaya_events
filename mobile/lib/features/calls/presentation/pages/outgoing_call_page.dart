import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';

class OutgoingCallPage extends StatelessWidget {
  const OutgoingCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.outgoingCall)),
      body: BlocBuilder<CallBloc, CallState>(
        builder: (context, state) {
          final call = state.outgoing;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.outgoingCall),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(state.error!, textAlign: TextAlign.center),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: call == null ? null : () => context.read<CallBloc>().add(CallEvent.end(call.id)),
                  child: Text(l10n.endCall),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
