import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../call_audio.dart';
import '../../domain/entities/call_entity.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';
import '../widgets/call_stage.dart';

class OutgoingCallPage extends StatelessWidget {
  const OutgoingCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final extraName = GoRouterState.of(context).extra is String ? GoRouterState.of(context).extra as String : null;
    return BlocConsumer<CallBloc, CallState>(
      listenWhen: (prev, next) => prev.outgoing != null && next.outgoing == null && next.active == null,
      listener: (context, state) {
        if (state.error == micPermissionError) {
          return;
        }
        if (context.canPop()) {
          context.pop();
        }
      },
      builder: (context, state) {
        final call = state.outgoing;
        final denied = state.error == micPermissionError;
        final name = extraName?.trim().isNotEmpty == true
            ? extraName!
            : call?.peerLabel(incoming: false, fallback: l10n.voiceCall) ?? l10n.voiceCall;
        return CallStage(
          name: name,
          initials: callInitials(name),
          status: denied
              ? l10n.micPermissionTitle
              : (state.error ?? (state.loading ? l10n.connectingCall : l10n.outgoingCall)),
          pulsing: !denied,
          permissionDenied: denied,
          onEnd: call == null || call.id == 'pending'
              ? () => context.pop()
              : () => context.read<CallBloc>().add(CallEvent.end(call.id)),
          onOpenSettings: openAppSettings,
          onRetry: () {
            final calleeId = call?.calleeId ?? call?.raw['calleeId']?.toString();
            if (calleeId == null || calleeId.isEmpty) {
              return;
            }
            context.read<CallBloc>().add(
              CallEvent.outgoing(calleeId: calleeId, bookingId: call?.raw['bookingId']?.toString()),
            );
          },
        );
      },
    );
  }
}
