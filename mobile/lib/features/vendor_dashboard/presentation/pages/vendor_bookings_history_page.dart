import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_settings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/domain/entities/bookings_item.dart';
import '../../../bookings/presentation/cubit/bookings_cubit.dart';
import '../../../bookings/presentation/cubit/bookings_state.dart';

class VendorBookingsHistoryPage extends StatefulWidget {
  const VendorBookingsHistoryPage({super.key});

  @override
  State<VendorBookingsHistoryPage> createState() =>
      _VendorBookingsHistoryPageState();
}

class _VendorBookingsHistoryPageState extends State<VendorBookingsHistoryPage> {
  String _filter = 'ALL';

  static const _incoming = {'INQUIRY', 'PENDING', 'UNDER_REVIEW', 'DRAFT'};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<BookingsCubit>()..load(query: {'pageSize': 50}),
      child: ScreenSync(
        topics: const [AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<BookingsCubit>().load(query: {'pageSize': 50}, silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(
              showBack: true,
              eyebrow: l10n.bookings,
              title: l10n.bookingHistory,
              subtitle: l10n.partnerSubtitle,
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                children: [
                  _chip(l10n.browse, 'ALL'),
                  _chip(l10n.incoming, 'INCOMING'),
                  _chip('CONFIRMED', 'CONFIRMED'),
                  _chip(l10n.paid, 'PAID'),
                  _chip('COMPLETED', 'COMPLETED'),
                  _chip('CANCELLED', 'CANCELLED'),
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
                    emptyTitle: l10n.empty,
                    emptyMessage: l10n.noBookingsYet,
                    onRetry: () => context.read<BookingsCubit>().load(
                      query: {'pageSize': 50},
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _BookingCard(item: items[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.yellow,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  bool _matches(BookingsItem item) {
    final status = (item.raw['status']?.toString() ?? '').toUpperCase();
    if (_filter == 'ALL') {
      return true;
    }
    if (_filter == 'INCOMING') {
      return _incoming.contains(status);
    }
    return status == _filter;
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});

  final BookingsItem item;

  @override
  Widget build(BuildContext context) {
    final raw = item.raw;
    final number = raw['bookingNumber']?.toString() ?? item.id;
    final status = raw['status']?.toString() ?? '';
    final amount = num.tryParse(raw['totalAmount']?.toString() ?? '') ?? 0;
    final currency = appCurrency(fallback: raw['currency']?.toString());
    final created = DateTime.tryParse(raw['createdAt']?.toString() ?? '');
    final date = created == null
        ? ''
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(created.toLocal());
    return Card(
      child: ListTile(
        onTap: () async {
          await context.push('/bookings/${item.id}');
          if (context.mounted) {
            context.read<BookingsCubit>().load(query: {'pageSize': 50}, silent: true);
          }
        },
        title: Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            currency,
            _money(amount),
            date,
          ].where((part) => part.isNotEmpty).join(' · '),
        ),
        trailing: StatusBadge(label: status),
      ),
    );
  }

  String _money(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match[1]},',
        );
  }
}
