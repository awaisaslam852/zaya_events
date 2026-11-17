import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/utils/customer_hub.dart';
import '../../core/widgets/zaya_dialogs.dart';
import '../../l10n/app_localizations.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_state.dart';
import 'domain/chat_usecases.dart';

String authenticatedUserId(BuildContext context) {
  return context.read<AuthBloc>().state.maybeWhen(authenticated: (user) => user.id, orElse: () => '');
}

String? vendorPeerIdForChat(BuildContext context, Map<String, dynamic> raw) {
  final myId = authenticatedUserId(context);
  final peer = bookingVendorUserId(raw);
  if (peer == null || peer.isEmpty || peer == myId) {
    return null;
  }
  return peer;
}

VoidCallback? onVendorChat(BuildContext context, Map<String, dynamic> raw) {
  final peer = vendorPeerIdForChat(context, raw);
  if (peer == null) {
    return null;
  }
  return () => openConversation(context, participantId: peer);
}

Future<void> openConversation(
  BuildContext context, {
  required String participantId,
  String? bookingId,
}) async {
  final l10n = AppLocalizations.of(context);
  if (participantId.isEmpty) {
    showZayaSnack(context, l10n.errorGeneric, kind: ZayaSnackKind.error);
    return;
  }
  final result = await sl<StartConversation>()(participantId, bookingId: bookingId);
  if (!context.mounted) {
    return;
  }
  await result.fold(
    (failure) async => showZayaSnack(context, failure.message, kind: ZayaSnackKind.error),
    (convo) async {
      final id = convo['id']?.toString() ?? '';
      if (id.isEmpty) {
        showZayaSnack(context, l10n.errorGeneric, kind: ZayaSnackKind.error);
        return;
      }
      await context.push('/chat/$id');
    },
  );
}
