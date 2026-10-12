import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';

class CallHistoryPage extends StatelessWidget {
  const CallHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.read<CallBloc>().add(const CallEvent.loadHistory());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.callHistory)),
      body: BlocBuilder<CallBloc, CallState>(
        builder: (context, state) {
          if (state.history.isEmpty) {
            return Center(child: Text(l10n.empty));
          }
          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final call = state.history[index];
              return ListTile(
                title: Text(call.status),
                subtitle: Text(call.id),
              );
            },
          );
        },
      ),
    );
  }
}
