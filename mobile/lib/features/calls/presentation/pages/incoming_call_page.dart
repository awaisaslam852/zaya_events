import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/call_entity.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/call_stage.dart';

class IncomingCallPage extends StatelessWidget {
  const IncomingCallPage({super.key, this.call});
  final CallEntity? call;

  @override
  Widget build(BuildContext context) {
    final incoming = call ?? context.select<CallBloc, CallEntity?>((bloc) => bloc.state.incoming);
    if (incoming == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final name = incoming.peerLabel(incoming: true, fallback: l10n.incomingCall);
    return CallStage(
      name: name,
      initials: incoming.initials(incoming: true),
      status: l10n.incomingCall,
      pulsing: true,
      showAccept: true,
      showBack: false,
      onReject: () {
        context.read<CallBloc>().add(CallEvent.reject(incoming.id));
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      onAccept: () {
        context.read<CallBloc>().add(CallEvent.accept(incoming.id));
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
