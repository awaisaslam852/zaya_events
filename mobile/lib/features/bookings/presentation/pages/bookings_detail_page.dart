import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/session_role.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/open_conversation.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';
import '../widgets/review_sheet.dart';

class BookingsDetailPage extends StatelessWidget {
  const BookingsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _run(BuildContext context, Future<String?> Function() action) async {
    final error = await action();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      showZayaSnack(context, error, kind: ZayaSnackKind.error);
    }
  }

  Future<void> _vendorAct(BuildContext context, String action) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showZayaConfirm(
      context,
      title: action == 'complete'
          ? l10n.completeBookingTitle
          : action == 'reject'
              ? l10n.rejectRequestTitle
              : l10n.confirmRequestTitle,
      message: action == 'complete'
          ? l10n.completeBookingMessage
          : action == 'reject'
              ? l10n.rejectRequestMessage
              : l10n.confirmRequestMessage,
      confirmLabel: action == 'complete'
          ? l10n.markComplete
          : action == 'reject'
              ? l10n.reject
              : l10n.confirm,
      cancelLabel: l10n.keepBooking,
      icon: action == 'complete'
          ? Icons.event_available_outlined
          : action == 'reject'
              ? Icons.close_rounded
              : Icons.check_circle_outline,
    );
    if (!ok || !context.mounted) {
      return;
    }
    await _run(context, () => context.read<BookingsCubit>().vendorAct(id, action));
  }

  Future<void> _review(BuildContext context) async {
    final isVendor = isVendorSession(context);
    final result = await showBookingReviewSheet(context, isVendor: isVendor);
    if (result == null || !context.mounted) {
      return;
    }
    final error = await context.read<BookingsCubit>().submitReview(
          id,
          rating: result.rating,
          comment: result.comment,
        );
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      showZayaSnack(context, error, kind: ZayaSnackKind.error);
      return;
    }
    showZayaSnack(context, AppLocalizations.of(context).reviewSubmitted, kind: ZayaSnackKind.success);
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showZayaConfirm(
      context,
      title: l10n.cancelBookingTitle,
      message: l10n.cancelBookingMessage,
      confirmLabel: l10n.cancel,
      cancelLabel: l10n.keepBooking,
      icon: Icons.event_busy_outlined,
    );
    if (!ok || !context.mounted) {
      return;
    }
    await _run(context, () => context.read<BookingsCubit>().cancel(id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingsCubit>()..loadOne(id),
      child: ScreenSync(
        topics: const [AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<BookingsCubit>().loadOne(id, silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            final item = state.detail;
            final myId = sessionUserId(context) ?? '';
            final isVendor = isVendorSession(context);
            final peerId = item == null ? null : bookingChatPeerId(item.raw, myId);
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<BookingsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : BookingDetailView(
                      raw: item.raw,
                      isVendor: isVendor,
                      onPay: (kind) => _pay(context, kind),
                      onModify: () => _modify(context, item.raw),
                      onCancel: () => _cancelBooking(context),
                      onVendorAct: isVendor ? (action) => _vendorAct(context, action) : null,
                      onReview: bookingCanReview(item.raw) ? () => _review(context) : null,
                      onChat: peerId == null
                          ? null
                          : () => openConversation(context, participantId: peerId, bookingId: id),
                    ),
            );
          },
        ),
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, String kind) async {
    if (isVendorSession(context)) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BookingsCubit>();
    final item = cubit.state.detail?.raw ?? <String, dynamic>{};
    final title = localized(bookingTitleRaw(item), Localizations.localeOf(context).languageCode);
    final start = await cubit.startPay(id, kind, title: title);
    if (!context.mounted) {
      return;
    }
    if (start.error != null) {
      showZayaSnack(context, start.error!, kind: ZayaSnackKind.error);
      return;
    }
    if (start.checkout != null) {
      final paid = await context.push<bool>('/payments/checkout', extra: start.checkout);
      if (!context.mounted) {
        return;
      }
      if (paid == true) {
        await cubit.loadOne(id);
        if (!context.mounted) {
          return;
        }
        showZayaSnack(context, l10n.paymentSuccess, kind: ZayaSnackKind.success);
      }
      return;
    }
    final result = start.receipt;
    if (result == null) {
      showZayaSnack(context, l10n.saveSuccess, kind: ZayaSnackKind.success);
      return;
    }
    if (result.startsWith('OK')) {
      final number = result.length > 3 ? result.substring(3) : l10n.receipt;
      showZayaSnack(context, '${l10n.receipt}: $number', kind: ZayaSnackKind.success);
      return;
    }
    showZayaSnack(context, result);
  }

  Future<void> _modify(BuildContext context, Map<String, dynamic> raw) async {
    final l10n = AppLocalizations.of(context);
    final guests = TextEditingController(text: '${raw['guestCount'] ?? ''}');
    DateTime start = DateTime.tryParse(raw['startAt']?.toString() ?? '')?.toLocal() ?? DateTime.now();
    final saved = await showZayaSheet<bool>(
      context: context,
      child: ZayaSheetScaffold(
        title: l10n.modifyBooking,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZayaTextField(controller: guests, label: l10n.guests, keyboardType: TextInputType.number),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.eventDate),
                    subtitle: Text(start.toIso8601String().split('T').first),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: start,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setSheet(() => start = DateTime(picked.year, picked.month, picked.day, start.hour, start.minute));
                      }
                    },
                  ),
                  ZayaPrimaryButton(
                    label: l10n.save,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    if (saved != true || !context.mounted) {
      guests.dispose();
      return;
    }
    await _run(
      context,
      () => context.read<BookingsCubit>().modify(id, {
        'startAt': start.toUtc().toIso8601String(),
        if (int.tryParse(guests.text.trim()) != null) 'guestCount': int.parse(guests.text.trim()),
      }),
    );
    guests.dispose();
  }
}

class BookingDetailView extends StatelessWidget {
  const BookingDetailView({
    super.key,
    required this.raw,
    required this.onPay,
    required this.onModify,
    required this.onCancel,
    this.isVendor = false,
    this.onVendorAct,
    this.onReview,
    this.onChat,
  });

  final Map<String, dynamic> raw;
  final Future<void> Function(String kind) onPay;
  final VoidCallback onModify;
  final VoidCallback onCancel;
  final bool isVendor;
  final Future<void> Function(String action)? onVendorAct;
  final VoidCallback? onReview;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final status = raw['status']?.toString() ?? '';
    final type = raw['type']?.toString();
    final currency = raw['currency']?.toString() ?? 'AED';
    final editable = !isVendor && const {'INQUIRY', 'PENDING', 'UNDER_REVIEW'}.contains(status);
    final cancellable = !isVendor && !const {'COMPLETED', 'CANCELLED', 'REJECTED', 'REFUNDED'}.contains(status);
    final canDeposit = bookingCanPay(raw, 'DEPOSIT');
    final canBalance = bookingCanPay(raw, 'BALANCE');
    final resource = bookingResource(raw);
    final image = resource == null ? null : catalogImageUrl(resource);
    final start = parseApiDate(raw['startAt']);
    final end = parseApiDate(raw['endAt']);
    final dateLabel = [
      if (start != null) DateFormat.yMMMd(locale.toString()).format(start),
      if (end != null) DateFormat.yMMMd(locale.toString()).format(end),
    ].join(' – ');
    final invoices = raw['invoices'] is List
        ? (raw['invoices'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : const <Map<String, dynamic>>[];
    final notes = localized(raw['notes'], locale.languageCode);
    final number = raw['bookingNumber']?.toString() ?? '';
    final showMoney = bookingHasAmount(raw);
    final venueId = raw['venueId']?.toString() ?? (raw['venue'] is Map ? (raw['venue'] as Map)['id']?.toString() : null);
    final chatLabel = isVendor ? l10n.messageGuest : l10n.messageVendor;
    final canReview = onReview != null && bookingCanReview(raw);
    final myReview = bookingReviewMine(raw);
    final theirReview = bookingReviewTheirs(raw);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 4, 16, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              l10n.myBookings.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.yellow,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (number.isNotEmpty)
                            Text(
                              number,
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localized(bookingTitleRaw(raw), locale.languageCode),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _HeroChip(icon: bookingTypeIcon(type), label: bookingTypeLabel(l10n, type)),
                                _HeroChip(icon: Icons.flag_outlined, label: prettyEnumLabel(status), yellow: true),
                              ],
                            ),
                            if (dateLabel.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                [
                                  dateLabel,
                                  if (raw['guestCount'] != null) '${raw['guestCount']} ${l10n.guests}',
                                ].join(' · '),
                                style: const TextStyle(color: Colors.white70, height: 1.35),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList.list(
                  children: [
                    if (image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(imageUrl: image, height: 188, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (onChat != null || (venueId != null && venueId.isNotEmpty)) ...[
                      Row(
                        children: [
                          if (onChat != null)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onChat,
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: Text(chatLabel),
                              ),
                            ),
                          if (onChat != null && venueId != null && venueId.isNotEmpty) const SizedBox(width: 10),
                          if (venueId != null && venueId.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/venues/$venueId'),
                                icon: const Icon(Icons.apartment_outlined),
                                label: Text(l10n.viewVenue),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (isVendor) ...[
                      _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.eventBrief, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(l10n.vendorBookingHint, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: l10n.guestName,
                              value: bookingGuestName(raw).isEmpty ? '—' : bookingGuestName(raw),
                            ),
                            _InfoRow(icon: Icons.event_outlined, label: l10n.eventDate, value: dateLabel.isEmpty ? '—' : dateLabel),
                            _InfoRow(
                              icon: Icons.groups_outlined,
                              label: l10n.guests,
                              value: '${raw['guestCount'] ?? 0}',
                              last: notes.isEmpty,
                            ),
                            if (notes.isNotEmpty) _InfoRow(icon: Icons.notes_outlined, label: l10n.notes, value: notes, last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (showMoney)
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.payments_outlined,
                              label: l10n.costOverview,
                              value: formatMoney(raw['totalAmount'], currency),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_outline,
                              label: isVendor ? l10n.guestPaid : l10n.paid,
                              value: formatMoney(bookingPaidTotal(raw), currency),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: isVendor ? l10n.outstanding : l10n.remaining,
                              value: formatMoney(raw['balanceAmount'], currency),
                            ),
                          ),
                        ],
                      )
                    else
                      _Panel(
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.navy),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.priceToConfirm,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    _Panel(
                      child: Column(
                        children: [
                          _InfoRow(icon: Icons.confirmation_number_outlined, label: l10n.receipt, value: number.isEmpty ? '—' : number),
                          _InfoRow(
                            icon: Icons.category_outlined,
                            label: l10n.category,
                            value: bookingTypeLabel(l10n, type),
                            last: isVendor,
                          ),
                          if (!isVendor) ...[
                            _InfoRow(icon: Icons.event_outlined, label: l10n.eventDate, value: dateLabel.isEmpty ? '—' : dateLabel),
                            _InfoRow(
                              icon: Icons.groups_outlined,
                              label: l10n.guests,
                              value: '${raw['guestCount'] ?? 0}',
                              last: notes.isEmpty,
                            ),
                            if (notes.isNotEmpty) _InfoRow(icon: Icons.notes_outlined, label: l10n.notes, value: notes, last: true),
                          ],
                        ],
                      ),
                    ),
                    if (invoices.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(l10n.invoice, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      for (final inv in invoices)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Panel(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppTheme.wash,
                                  child: Icon(Icons.receipt_long_outlined, color: AppTheme.navy, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${l10n.invoice} ${inv['invoiceNumber'] ?? ''}',
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        '${inv['status'] ?? ''} · ${formatMoney(inv['totalAmount'], inv['currency']?.toString() ?? currency)}',
                                        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    if (myReview != null || theirReview != null) ...[
                      const SizedBox(height: 22),
                      Text(l10n.reviews, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      if (myReview != null) _PostedReview(title: l10n.yourReview, review: myReview),
                      if (theirReview != null)
                        _PostedReview(
                          title: isVendor ? l10n.reviewFromGuest : l10n.reviewFromVendor,
                          review: theirReview,
                        ),
                    ],
                    if ((editable && !isVendor) || cancellable) ...[
                      const SizedBox(height: 18),
                      if (editable && !isVendor)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onModify,
                            icon: const Icon(Icons.edit_calendar_outlined),
                            label: Text(l10n.modifyBooking),
                          ),
                        ),
                      if (cancellable) ...[
                        if (editable) const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB91C1C),
                              side: const BorderSide(color: Color(0xFFF3C1C1)),
                            ),
                            icon: const Icon(Icons.event_busy_outlined),
                            label: Text(l10n.cancel),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isVendor && (canDeposit || canBalance))
          Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: AppTheme.navy.withValues(alpha: 0.12),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    if (canDeposit)
                      ZayaPrimaryButton(
                        label: '${l10n.payDeposit} · ${formatMoney(raw['depositAmount'], currency)}',
                        icon: Icons.payments_outlined,
                        onPressed: () => onPay('DEPOSIT'),
                      ),
                    if (canDeposit && canBalance) const SizedBox(height: 8),
                    if (canBalance)
                      SizedBox(
                        width: double.infinity,
                        child: canDeposit
                            ? OutlinedButton.icon(
                                onPressed: () => onPay('BALANCE'),
                                icon: const Icon(Icons.account_balance_wallet_outlined),
                                label: Text('${l10n.payBalance} · ${formatMoney(raw['balanceAmount'], currency)}'),
                              )
                            : FilledButton.icon(
                                onPressed: () => onPay('BALANCE'),
                                icon: const Icon(Icons.account_balance_wallet_outlined),
                                label: Text('${l10n.payBalance} · ${formatMoney(raw['balanceAmount'], currency)}'),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          )
        else if (isVendor && onVendorAct != null && bookingNeedsVendorDecision(status))
          Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: AppTheme.navy.withValues(alpha: 0.12),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onVendorAct!('reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB91C1C),
                          side: const BorderSide(color: Color(0xFFF3C1C1)),
                        ),
                        child: Text(l10n.reject),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => onVendorAct!('confirm'),
                        child: Text(l10n.confirm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (isVendor && onVendorAct != null && status == 'CONFIRMED')
          Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: AppTheme.navy.withValues(alpha: 0.12),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: ZayaPrimaryButton(
                  label: l10n.markComplete,
                  icon: Icons.event_available_outlined,
                  onPressed: () => onVendorAct!('complete'),
                ),
              ),
            ),
          )
        else if (canReview)
          Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: AppTheme.navy.withValues(alpha: 0.12),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: ZayaPrimaryButton(
                  label: isVendor ? l10n.rateGuest : l10n.rateVendor,
                  icon: Icons.star_outline,
                  onPressed: onReview,
                ),
              ),
            ),
          )
        else if (onChat != null)
          Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: AppTheme.navy.withValues(alpha: 0.12),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: ZayaPrimaryButton(
                  label: chatLabel,
                  icon: Icons.chat_bubble_outline,
                  onPressed: onChat,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label, this.yellow = false});
  final IconData icon;
  final String label;
  final bool yellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: yellow ? AppTheme.yellow : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: yellow ? const Color(0xFF1A1A1A) : Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: yellow ? const Color(0xFF1A1A1A) : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.navy, size: 18),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.navy),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostedReview extends StatelessWidget {
  const _PostedReview({required this.title, required this.review});
  final String title;
  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final comment = localized(review['body'], locale);
    final rating = num.tryParse('${review['rating'] ?? 0}') ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ReviewStars(rating: rating),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment, style: const TextStyle(height: 1.4, color: AppTheme.ink)),
            ],
          ],
        ),
      ),
    );
  }
}
