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
import '../../../../core/widgets/location_map_card.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/open_conversation.dart';
import '../../visit_copy.dart';
import '../cubit/visits_cubit.dart';
import '../cubit/visits_state.dart';

class VisitsDetailPage extends StatelessWidget {
  const VisitsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _run(BuildContext context, Future<String?> Function() action, {String? success}) async {
    final error = await action();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      showZayaSnack(context, error, kind: ZayaSnackKind.error);
      return;
    }
    if (success != null) {
      showZayaSnack(context, success, kind: ZayaSnackKind.success);
    }
  }

  bool _isVendor(BuildContext context) => isVendorSession(context);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VisitsCubit>()..loadOne(id),
      child: ScreenSync(
        topics: const [AppRefreshTopic.visits],
        onRefresh: (context) => context.read<VisitsCubit>().loadOne(id, silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<VisitsCubit, VisitsState>(
          builder: (context, state) {
            final item = state.detail;
            final vendor = _isVendor(context);
            final l10n = AppLocalizations.of(context);
            final myId = sessionUserId(context) ?? '';
            final peerId = item == null ? null : visitChatPeerId(item.raw, myId);
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<VisitsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : VisitDetailView(
                      raw: item.raw,
                      isVendor: vendor,
                      onChat: peerId == null ? null : () => openConversation(context, participantId: peerId),
                      onCancel: () async {
                        final ok = await showZayaConfirm(
                          context,
                          title: l10n.cancelVisitTitle,
                          message: l10n.cancelVisitMessage,
                          confirmLabel: vendor ? l10n.declineVisit : l10n.cancelVisit,
                          cancelLabel: l10n.keepVisit,
                          icon: Icons.event_busy_outlined,
                        );
                        if (!ok || !context.mounted) {
                          return;
                        }
                        await _run(context, () => context.read<VisitsCubit>().cancel(id));
                      },
                      onApprove: () async {
                        final ok = await showZayaConfirm(
                          context,
                          title: l10n.acceptVisitTitle,
                          message: l10n.acceptVisitMessage,
                          confirmLabel: l10n.acceptVisit,
                          icon: Icons.check_circle_outline,
                          tone: ZayaConfirmTone.primary,
                        );
                        if (!ok || !context.mounted) {
                          return;
                        }
                        await _run(context, () => context.read<VisitsCubit>().approve(id), success: l10n.visitAccepted);
                      },
                      onComplete: () async {
                        final ok = await showZayaConfirm(
                          context,
                          title: l10n.completeVisitTitle,
                          message: l10n.completeVisitMessage,
                          confirmLabel: l10n.completeVisit,
                          icon: Icons.task_alt_outlined,
                          tone: ZayaConfirmTone.primary,
                        );
                        if (!ok || !context.mounted) {
                          return;
                        }
                        await _run(
                          context,
                          () => context.read<VisitsCubit>().complete(id),
                          success: l10n.visitMarkedComplete,
                        );
                      },
                      onDecide: (accepted) async {
                        final ok = await showZayaConfirm(
                          context,
                          title: accepted ? l10n.willBookTitle : l10n.wontBookTitle,
                          message: accepted ? l10n.willBookMessage : l10n.wontBookMessage,
                          confirmLabel: accepted ? l10n.confirm : l10n.wontBook,
                          icon: accepted ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
                          tone: accepted ? ZayaConfirmTone.primary : ZayaConfirmTone.danger,
                        );
                        if (!ok || !context.mounted) {
                          return;
                        }
                        await _run(context, () => context.read<VisitsCubit>().decide(id, accepted: accepted));
                      },
                    ),
            );
          },
        ),
        ),
      ),
    );
  }
}

class VisitDetailView extends StatelessWidget {
  const VisitDetailView({
    super.key,
    required this.raw,
    this.isVendor = false,
    this.onChat,
    this.onCancel,
    this.onApprove,
    this.onComplete,
    this.onDecide,
  });

  final Map<String, dynamic> raw;
  final bool isVendor;
  final VoidCallback? onChat;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onComplete;
  final Future<void> Function(bool accepted)? onDecide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final venue = raw['venue'] is Map ? Map<String, dynamic>.from(raw['venue'] as Map) : <String, dynamic>{};
    final representative =
        raw['representative'] is Map ? Map<String, dynamic>.from(raw['representative'] as Map) : null;
    final status = raw['status']?.toString() ?? '';
    final terminal = visitIsTerminal(status);
    final canApprove = isVendor && visitCanApprove(status);
    final canComplete = isVendor && visitCanComplete(status);
    final canDecide = !isVendor && visitCanDecide(status);
    final guestName = visitGuestName(raw);
    final date = parseApiDate(raw['scheduledAt']);
    final image = catalogImageUrl(venue);
    final notes = localized(raw['notes'], locale.languageCode);
    final decision = raw['decision'] is Map ? Map<String, dynamic>.from(raw['decision'] as Map) : null;
    final title = localized(venue['name'] ?? raw['title'], locale.languageCode);
    final city = venue['city']?.toString() ?? '';
    final venueId = venue['id']?.toString() ?? raw['venueId']?.toString() ?? '';
    final guests = catalogGuestRange(venue);
    final price = catalogPrice(venue);
    final countdown = date == null ? '' : eventCountdownLabel(l10n, raw['scheduledAt']);
    final hostName = representative == null ? '' : localized(representative['name'], locale.languageCode);
    final hostPhone = representative?['phone']?.toString() ?? '';
    final map = LocationMapCard.maybe(venue, label: city.isEmpty ? title : city);
    final hint = visitStatusHint(l10n, status, vendor: isVendor);

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
                  padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 4, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Text(
                            l10n.venueVisits.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.yellow,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Chip(label: visitStatusLabel(l10n, status), yellow: true),
                                if (city.isNotEmpty) _Chip(icon: Icons.place_outlined, label: city),
                              ],
                            ),
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
                    _VenueHero(
                      image: image,
                      onOpen: venueId.isEmpty ? null : () => context.push('/venues/$venueId'),
                      openLabel: l10n.viewVenue,
                    ),
                    const SizedBox(height: 12),
                    if (hint.isNotEmpty)
                      _InfoCard(
                        icon: Icons.schedule_outlined,
                        title: l10n.visitWhatsNext,
                        child: Text(hint, style: const TextStyle(color: AppTheme.ink, height: 1.45, fontSize: 14)),
                      ),
                    if (isVendor && guestName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.person_outline,
                        title: l10n.visitGuest,
                        child: Text(guestName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ],
                    if (date != null) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.calendar_month_outlined,
                        title: l10n.visitSchedule,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMMEEEEd(locale.toString()).format(date),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.ink),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.jm(locale.toString()).format(date),
                              style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600),
                            ),
                            if (countdown.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: AppTheme.wash, borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  countdown,
                                  style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (hostName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.person_outline,
                        title: l10n.visitHost,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hostName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            if (hostPhone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(hostPhone, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.notes_outlined,
                        title: l10n.notes,
                        child: Text(notes, style: const TextStyle(height: 1.45, color: AppTheme.ink, fontSize: 15)),
                      ),
                    ],
                    if (decision != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: decision['accepted'] == true ? const Color(0xFFF3F8F4) : const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: decision['accepted'] == true ? const Color(0xFFB7E0C2) : const Color(0xFFF3C1C1),
                          ),
                        ),
                        child: Text(
                          decision['accepted'] == true ? l10n.willBook : l10n.wontBook,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                    if (guests != null || price != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (guests != null)
                            Expanded(
                              child: _StatTile(
                                icon: Icons.groups_outlined,
                                label: l10n.guests,
                                value: guests,
                              ),
                            ),
                          if (guests != null && price != null) const SizedBox(width: 10),
                          if (price != null)
                            Expanded(
                              child: _StatTile(
                                icon: Icons.payments_outlined,
                                label: l10n.startingPrice,
                                value: l10n.fromPrice(price),
                                highlight: true,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (map != null) ...[
                      const SizedBox(height: 16),
                      Text(l10n.location, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.ink)),
                      const SizedBox(height: 10),
                      map,
                    ],
                    if (onChat != null || venueId.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (onChat != null)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onChat,
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: Text(isVendor ? l10n.messageGuest : l10n.messageVendor),
                              ),
                            ),
                          if (onChat != null && venueId.isNotEmpty) const SizedBox(width: 10),
                          if (venueId.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/venues/$venueId'),
                                icon: const Icon(Icons.apartment_outlined),
                                label: Text(l10n.viewVenue),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (!terminal && onCancel != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB91C1C),
                            side: const BorderSide(color: Color(0xFFF3C1C1)),
                          ),
                          icon: const Icon(Icons.event_busy_outlined),
                          label: Text(isVendor && canApprove ? l10n.declineVisit : l10n.cancelVisit),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (canApprove && onApprove != null)
          Material(
            color: Colors.white,
            elevation: 12,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: ZayaPrimaryButton(
                  label: l10n.acceptVisit,
                  icon: Icons.check_circle_outline,
                  onPressed: onApprove,
                ),
              ),
            ),
          )
        else if (canComplete && onComplete != null)
          Material(
            color: Colors.white,
            elevation: 12,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: ZayaPrimaryButton(
                  label: l10n.completeVisit,
                  icon: Icons.task_alt_outlined,
                  onPressed: onComplete,
                ),
              ),
            ),
          )
        else if (canDecide && onDecide != null)
          Material(
            color: Colors.white,
            elevation: 12,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    ZayaPrimaryButton(
                      label: l10n.willBook,
                      icon: Icons.thumb_up_alt_outlined,
                      onPressed: () => onDecide!(true),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onDecide!(false),
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        label: Text(l10n.wontBook),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VenueHero extends StatelessWidget {
  const _VenueHero({required this.image, required this.onOpen, required this.openLabel});

  final String? image;
  final VoidCallback? onOpen;
  final String openLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 188,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image == null
                ? const ColoredBox(
                    color: Color(0xFF003580),
                    child: Icon(Icons.apartment_outlined, color: Colors.white54, size: 48),
                  )
                : CachedNetworkImage(imageUrl: image!, fit: BoxFit.cover),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x9900183D)],
                  ),
                ),
              ),
            ),
            if (onOpen != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.tonal(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.navy,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(openLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.navy),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.muted)),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, this.highlight = false});

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight ? AppTheme.priceWash : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.navy),
            const SizedBox(height: 8),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.yellow = false, this.icon});
  final String label;
  final bool yellow;
  final IconData? icon;

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
          if (icon != null) ...[
            Icon(icon, size: 13, color: yellow ? const Color(0xFF1A1A1A) : Colors.white),
            const SizedBox(width: 4),
          ],
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
