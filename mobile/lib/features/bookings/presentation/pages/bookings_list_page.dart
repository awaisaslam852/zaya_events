import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/bookings_item.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';

class BookingsListPage extends StatelessWidget {
  const BookingsListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingsCubit>()..load(query: {'pageSize': 50}),
      child: ScreenSync(
        topics: const [AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<BookingsCubit>().load(query: {'pageSize': 50}, silent: true),
        child: const _BookingsView(),
      ),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  String _filter = 'ALL';

  static const _inquiry = {'INQUIRY', 'PENDING', 'UNDER_REVIEW', 'DRAFT'};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            eyebrow: l10n.myBookings,
            title: l10n.bookingsHeadline,
            subtitle: l10n.bookingsSubtitle,
          ),
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              scrollDirection: Axis.horizontal,
              children: [
                _pill(l10n.allFilter, 'ALL'),
                _pill(l10n.inquire, 'INQUIRY'),
                _pill(l10n.confirm, 'CONFIRMED'),
                _pill(l10n.paid, 'PAID'),
                _pill(l10n.complete, 'COMPLETED'),
                _pill(l10n.cancel, 'CANCELLED'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<BookingsCubit, BookingsState>(
              builder: (context, state) {
                final items = state.items.where(_matches).toList();
                return AsyncBody(
                  loading: state.loading,
                  error: state.error,
                  empty: items.isEmpty,
                  emptyIcon: Icons.receipt_long_outlined,
                  emptyTitle: l10n.noBookingsYet,
                  emptyMessage: l10n.noBookingsHint,
                  emptyActionLabel: l10n.browseToBook,
                  onEmptyAction: () => context.push('/customer/venues'),
                  onRetry: () => context.read<BookingsCubit>().load(query: {'pageSize': 50}),
                  child: RefreshIndicator(
                    color: AppTheme.navy,
                    onRefresh: () => context.read<BookingsCubit>().load(query: {'pageSize': 50}, silent: true),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _BookingCard(item: items[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterPill(
        label: label,
        selected: _filter == value,
        onTap: () => setState(() => _filter = value),
      ),
    );
  }

  bool _matches(BookingsItem item) {
    final status = (item.raw['status']?.toString() ?? '').toUpperCase();
    if (_filter == 'ALL') {
      return true;
    }
    if (_filter == 'INQUIRY') {
      return _inquiry.contains(status);
    }
    if (_filter == 'CANCELLED') {
      return const {'CANCELLED', 'REJECTED', 'REFUNDED'}.contains(status);
    }
    return status == _filter;
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});
  final BookingsItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final raw = item.raw;
    final type = raw['type']?.toString();
    final status = raw['status']?.toString() ?? '';
    final resource = bookingResource(raw);
    final image = resource == null ? null : catalogImageUrl(resource);
    final start = parseApiDate(raw['startAt']);
    final date = start == null ? '' : DateFormat.yMMMd(locale.toString()).format(start);
    final currency = raw['currency']?.toString() ?? 'AED';
    final number = raw['bookingNumber']?.toString() ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          await context.push('/bookings/${item.id}');
          if (context.mounted) {
            context.read<BookingsCubit>().load(query: {'pageSize': 50}, silent: true);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: image == null
                        ? ColoredBox(
                            color: favoriteTypeWash(type),
                            child: Icon(bookingTypeIcon(type), color: AppTheme.navy, size: 32),
                          )
                        : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              localized(bookingTitleRaw(raw), locale.languageCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.ink),
                            ),
                          ),
                          StatusBadge(label: status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          bookingTypeLabel(l10n, type),
                          if (number.isNotEmpty) number,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (date.isNotEmpty) ...[
                            const Icon(Icons.event_outlined, size: 14, color: AppTheme.muted),
                            const SizedBox(width: 4),
                            Text(date, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                          ] else
                            const Spacer(),
                          Text(
                            formatMoney(raw['totalAmount'], currency),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
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
