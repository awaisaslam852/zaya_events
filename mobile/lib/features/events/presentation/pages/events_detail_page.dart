import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsDetailPage extends StatelessWidget {
  const EventsDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventsCubit>()..loadOne(id),
      child: ScreenSync(
        topics: const [AppRefreshTopic.events, AppRefreshTopic.bookings, AppRefreshTopic.visits],
        onRefresh: (context) => context.read<EventsCubit>().loadOne(id, silent: true),
        child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.canvas,
            body: BlocBuilder<EventsCubit, EventsState>(
              builder: (context, state) {
                final item = state.detail;
                return AsyncBody(
                  loading: state.loading,
                  error: state.error,
                  empty: item == null,
                  onRetry: () => context.read<EventsCubit>().loadOne(id),
                  child: item == null ? const SizedBox.shrink() : _Hub(raw: item.raw, eventId: id),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }
}

class _Hub extends StatelessWidget {
  const _Hub({required this.raw, required this.eventId});
  final Map<String, dynamic> raw;
  final String eventId;

  String _money(dynamic value, String currency) {
    final amount = num.tryParse('$value') ?? 0;
    return '$currency ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cost = raw['cost'] is Map ? Map<String, dynamic>.from(raw['cost'] as Map) : <String, dynamic>{};
    final currency = cost['currency']?.toString() ?? raw['currency']?.toString() ?? 'AED';
    final bookings = (raw['bookings'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final visits = (raw['visits'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final checklist = (raw['checklist'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final travel = bookings.where((b) => ['FLIGHT', 'HOTEL'].contains(b['type']?.toString())).toList();
    final date = parseApiDate(raw['eventDate']);
    final end = parseApiDate(raw['endDate']);
    final dateLabel = [
      if (date != null) DateFormat.yMMMd(locale).format(date),
      if (end != null) DateFormat.yMMMd(locale).format(end),
    ].join(' – ');
    final doneCount = checklist.where((item) => item['done'] == true).length;

    return CustomScrollView(
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
            padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 4, 8, 22),
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
                        l10n.eventHub.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.yellow,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () async {
                        final updated = await context.push<bool>('/events/$eventId/edit');
                        if (context.mounted && updated == true) {
                          context.read<EventsCubit>().loadOne(eventId);
                        }
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localized(raw['title'], locale),
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeroChip(icon: Icons.flag_outlined, label: raw['status']?.toString() ?? 'planning'),
                          if ((raw['city']?.toString() ?? '').isNotEmpty)
                            _HeroChip(icon: Icons.place_outlined, label: '${raw['city']}'),
                          if (eventCountdownLabel(l10n, raw['eventDate']).isNotEmpty)
                            _HeroChip(icon: Icons.schedule_outlined, label: eventCountdownLabel(l10n, raw['eventDate']), yellow: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        [
                          dateLabel,
                          '${raw['guestCount'] ?? 0} ${l10n.guests}',
                        ].where((part) => part.isNotEmpty).join(' · '),
                        style: const TextStyle(color: Colors.white70, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(label: l10n.paid, value: _money(cost['paid'], currency), icon: Icons.payments_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: l10n.remaining, value: _money(cost['remaining'], currency), icon: Icons.account_balance_wallet_outlined)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: l10n.checklist,
                      value: checklist.isEmpty ? '—' : '$doneCount/${checklist.length}',
                      icon: Icons.checklist_rtl,
                    ),
                  ),
                ],
              ),
              if (localized(raw['notes'], locale).isNotEmpty) ...[
                const SizedBox(height: 14),
                _Panel(
                  child: Text(localized(raw['notes'], locale), style: const TextStyle(height: 1.4)),
                ),
              ],
              const SizedBox(height: 22),
              Text(l10n.addToEvent, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.55,
                children: [
                  _AddTile(icon: Icons.apartment_outlined, title: l10n.venues, onTap: () => context.push('/customer/venues')),
                  _AddTile(icon: Icons.auto_awesome_outlined, title: l10n.services, onTap: () => context.push('/customer/listings')),
                  _AddTile(icon: Icons.directions_car_outlined, title: l10n.cars, onTap: () => context.push('/customer/cars')),
                  _AddTile(icon: Icons.hotel_outlined, title: l10n.accommodations, onTap: () => context.push('/customer/stays')),
                  _AddTile(icon: Icons.flight_takeoff_outlined, title: l10n.flights, onTap: () => context.push('/customer/flights')),
                  _AddTile(icon: Icons.auto_awesome, title: l10n.aiPlanner, onTap: () => context.push('/customer/ai')),
                ],
              ),
              const SizedBox(height: 22),
              _Section(
                title: l10n.checklist,
                empty: checklist.isEmpty,
                children: [
                  for (final item in checklist)
                    _CheckRow(
                      title: localized(item['title'], locale),
                      done: item['done'] == true,
                      onChanged: (value) {
                        final next = checklist
                            .map(
                              (row) => {
                                ...row,
                                'done': row['id']?.toString() == item['id']?.toString() ? value : row['done'] == true,
                              },
                            )
                            .toList();
                        context.read<EventsCubit>().update(eventId, {'checklist': next});
                      },
                    ),
                ],
              ),
              _Section(
                title: l10n.bookings,
                empty: bookings.isEmpty,
                children: [
                  for (final booking in bookings)
                    _LinkRow(
                      icon: Icons.receipt_long_outlined,
                      title: localized(
                        booking['venue'] is Map
                            ? (booking['venue'] as Map)['name']
                            : booking['listing'] is Map
                                ? (booking['listing'] as Map)['title']
                                : booking['bookingNumber'] ?? booking['type'],
                        locale,
                      ),
                      subtitle: '${booking['type']} · ${booking['status']}',
                      onTap: () => context.push('/bookings/${booking['id']}'),
                    ),
                ],
              ),
              _Section(
                title: l10n.venueVisits,
                empty: visits.isEmpty,
                children: [
                  for (final visit in visits)
                    _LinkRow(
                      icon: Icons.meeting_room_outlined,
                      title: localized(visit['venue'] is Map ? (visit['venue'] as Map)['name'] : l10n.venueVisits, locale),
                      subtitle: '${parseApiDate(visit['scheduledAt'])?.toString().split(' ').first ?? ''} · ${visit['status']}',
                      onTap: () => context.push('/venue_visits/${visit['id']}'),
                    ),
                ],
              ),
              _Section(
                title: l10n.travel,
                empty: travel.isEmpty,
                children: [
                  for (final trip in travel)
                    _LinkRow(
                      icon: trip['type'] == 'FLIGHT' ? Icons.flight_takeoff : Icons.hotel_outlined,
                      title: trip['bookingNumber']?.toString() ?? trip['type']?.toString() ?? '',
                      subtitle: '${trip['type']} · ${trip['status']}',
                      onTap: () => context.push('/bookings/${trip['id']}'),
                    ),
                ],
              ),
            ],
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
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

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
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: child,
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.line),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppTheme.wash, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppTheme.navy, size: 20),
                ),
                const Spacer(),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.title, required this.done, required this.onChanged});
  final String title;
  final bool done;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: done ? const Color(0xFFF3F8F4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => onChanged(!done),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: done ? const Color(0xFFB7E0C2) : AppTheme.line),
            ),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: done ? const Color(0xFF0F766E) : AppTheme.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? AppTheme.muted : AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.wash,
                  child: Icon(icon, color: AppTheme.navy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.navy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, required this.empty});
  final String title;
  final List<Widget> children;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          if (empty)
            Text(AppLocalizations.of(context).empty, style: const TextStyle(color: AppTheme.muted))
          else
            ...children,
        ],
      ),
    );
  }
}
