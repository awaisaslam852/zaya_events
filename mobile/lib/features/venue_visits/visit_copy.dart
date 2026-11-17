import '../../core/utils/customer_hub.dart';
import '../../l10n/app_localizations.dart';

String visitStatusLabel(AppLocalizations l10n, String status) {
  return switch (status.toUpperCase()) {
    'REQUESTED' => l10n.visitStatusRequested,
    'APPROVED' => l10n.visitStatusApproved,
    'RESCHEDULED' => l10n.visitStatusRescheduled,
    'CONFIRMED' => l10n.visitStatusConfirmed,
    'COMPLETED' => l10n.visitStatusCompleted,
    'DECIDED' => l10n.visitStatusDecided,
    'CANCELLED' => l10n.visitStatusCancelled,
    'NO_SHOW' => l10n.visitStatusNoShow,
    _ => status,
  };
}

String visitStatusHint(AppLocalizations l10n, String status, {bool vendor = false}) {
  final code = status.toUpperCase();
  if (vendor) {
    return switch (code) {
      'REQUESTED' => l10n.vendorRequestedHint,
      'APPROVED' || 'RESCHEDULED' => l10n.vendorApprovedHint,
      'CONFIRMED' => l10n.vendorConfirmedHint,
      'COMPLETED' => l10n.vendorCompletedHint,
      'DECIDED' => l10n.visitDecidedHint,
      'CANCELLED' => l10n.visitCancelledHint,
      'NO_SHOW' => l10n.visitNoShowHint,
      _ => '',
    };
  }
  return switch (code) {
    'REQUESTED' => l10n.visitRequestedHint,
    'APPROVED' => l10n.visitApprovedHint,
    'RESCHEDULED' => l10n.visitRescheduledHint,
    'CONFIRMED' => l10n.visitConfirmedHint,
    'COMPLETED' => l10n.visitCompletedHint,
    'DECIDED' => l10n.visitDecidedHint,
    'CANCELLED' => l10n.visitCancelledHint,
    'NO_SHOW' => l10n.visitNoShowHint,
    _ => '',
  };
}

bool visitIsTerminal(String status) => const {'CANCELLED', 'DECIDED', 'NO_SHOW'}.contains(status.toUpperCase());

bool visitCanApprove(String status) => status.toUpperCase() == 'REQUESTED';

bool visitCanComplete(String status) =>
    const {'APPROVED', 'RESCHEDULED', 'CONFIRMED'}.contains(status.toUpperCase());

bool visitCanDecide(String status) => const {'CONFIRMED', 'COMPLETED'}.contains(status.toUpperCase());

String? visitChatPeerId(Map<String, dynamic> raw, String myId) {
  final venue = raw['venue'] is Map ? Map<String, dynamic>.from(raw['venue'] as Map) : const <String, dynamic>{};
  return bookingChatPeerId({
    'vendor': venue['vendor'] ?? raw['vendor'],
    'customer': raw['customer'],
    'customerId': raw['customerId'],
  }, myId);
}

String visitGuestName(Map<String, dynamic> raw) {
  final customer = raw['customer'] is Map ? Map<String, dynamic>.from(raw['customer'] as Map) : const <String, dynamic>{};
  final name = '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim();
  if (name.isNotEmpty) {
    return name;
  }
  final display = customer['displayName']?.toString() ?? '';
  if (display.isNotEmpty) {
    return display;
  }
  return customer['email']?.toString() ?? '';
}
