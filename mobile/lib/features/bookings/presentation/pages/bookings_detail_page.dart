import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';

class BookingsDetailPage extends StatelessWidget {
  const BookingsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _run(BuildContext context, Future<String?> Function() action) async {
    final error = await action();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<BookingsCubit>()..loadOne(id),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.bookings)),
        body: BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<BookingsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : Builder(
                      builder: (context) {
                        final raw = item.raw;
                        final locale = Localizations.localeOf(context).languageCode;
                        final status = raw['status']?.toString() ?? '';
                        final editable = const {'INQUIRY', 'PENDING', 'UNDER_REVIEW'}.contains(status);
                        final cancellable = !const {'COMPLETED', 'CANCELLED', 'REJECTED', 'REFUNDED'}.contains(status);
                        final name = raw['venue'] is Map
                            ? (raw['venue'] as Map)['name']
                            : raw['listing'] is Map
                                ? (raw['listing'] as Map)['title']
                                : raw['car'] is Map
                                    ? (raw['car'] as Map)['name']
                                    : raw['accommodation'] is Map
                                        ? (raw['accommodation'] as Map)['name']
                                        : raw['honeymoon'] is Map
                                            ? (raw['honeymoon'] as Map)['name']
                                            : raw['bookingNumber'];
                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            JsonTitle(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            StatusBadge(label: '${raw['type']} · $status'),
                            const SizedBox(height: 12),
                            Text(raw['startAt']?.toString().replaceFirst('T', ' ').split('.').first ?? ''),
                            if (raw['endAt'] != null) Text('${raw['endAt']}'.replaceFirst('T', ' ').split('.').first),
                            const SizedBox(height: 8),
                            Text('${raw['guestCount'] ?? 0} ${l10n.guests}'),
                            if (localized(raw['notes'], locale).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(localized(raw['notes'], locale)),
                            ],
                            const SizedBox(height: 12),
                            Text('${l10n.costOverview}: ${raw['totalAmount'] ?? ''} ${raw['currency'] ?? 'AED'}'),
                            Text('${l10n.paid}: ${_paidTotal(raw)} · ${l10n.remaining}: ${raw['balanceAmount'] ?? ''}'),
                            ..._invoices(raw).map(
                              (inv) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.receipt_long_outlined),
                                title: Text('${l10n.invoice} ${inv['invoiceNumber'] ?? ''}'),
                                subtitle: Text('${inv['status'] ?? ''} · ${inv['totalAmount'] ?? ''} ${inv['currency'] ?? raw['currency'] ?? 'AED'}'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_canPay(raw, 'DEPOSIT'))
                              ZayaPrimaryButton(
                                label: '${l10n.payDeposit} · ${raw['depositAmount'] ?? ''} ${raw['currency'] ?? 'AED'}',
                                icon: Icons.payments_outlined,
                                onPressed: () => _pay(context, 'DEPOSIT'),
                              ),
                            if (_canPay(raw, 'BALANCE')) ...[
                              const SizedBox(height: 8),
                              ZayaPrimaryButton(
                                label: '${l10n.payBalance} · ${raw['balanceAmount'] ?? ''} ${raw['currency'] ?? 'AED'}',
                                icon: Icons.account_balance_wallet_outlined,
                                onPressed: () => _pay(context, 'BALANCE'),
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (editable)
                              ZayaPrimaryButton(
                                label: l10n.modifyBooking,
                                icon: Icons.edit_calendar_outlined,
                                onPressed: () => _modify(context, raw),
                              ),
                            if (cancellable) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _run(context, () => context.read<BookingsCubit>().cancel(id)),
                                child: Text(l10n.cancel, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  bool _kindPaid(Map<String, dynamic> raw, String kind) {
    return _payments(raw).any((row) => row['kind'] == kind && row['status'] == 'SUCCEEDED');
  }

  bool _canPay(Map<String, dynamic> raw, String kind) {
    final status = raw['status']?.toString() ?? '';
    if (const {'CANCELLED', 'REJECTED', 'REFUNDED'}.contains(status)) {
      return false;
    }
    final amount = num.tryParse('${raw[kind == 'DEPOSIT' ? 'depositAmount' : 'balanceAmount'] ?? 0}') ?? 0;
    if (amount <= 0 || _kindPaid(raw, kind)) {
      return false;
    }
    if (kind == 'BALANCE' && !_kindPaid(raw, 'DEPOSIT') && (num.tryParse('${raw['depositAmount'] ?? 0}') ?? 0) > 0) {
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _payments(Map<String, dynamic> raw) {
    final list = raw['payments'];
    if (list is! List) {
      return const [];
    }
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> _invoices(Map<String, dynamic> raw) {
    final list = raw['invoices'];
    if (list is! List) {
      return const [];
    }
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String _paidTotal(Map<String, dynamic> raw) {
    final sum = _payments(raw)
        .where((row) => row['status'] == 'SUCCEEDED')
        .fold<num>(0, (acc, row) => acc + (num.tryParse('${row['amount'] ?? 0}') ?? 0));
    return '$sum ${raw['currency'] ?? 'AED'}';
  }

  Future<void> _pay(BuildContext context, String kind) async {
    final l10n = AppLocalizations.of(context);
    final result = await context.read<BookingsCubit>().pay(id, kind);
    if (!context.mounted) {
      return;
    }
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
      return;
    }
    if (result.startsWith('OK')) {
      final number = result.length > 3 ? result.substring(3) : l10n.receipt;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.receipt}: $number')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> _modify(BuildContext context, Map<String, dynamic> raw) async {
    final l10n = AppLocalizations.of(context);
    final guests = TextEditingController(text: '${raw['guestCount'] ?? ''}');
    DateTime start = DateTime.tryParse(raw['startAt']?.toString() ?? '')?.toLocal() ?? DateTime.now();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.modifyBooking, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  ZayaTextField(controller: guests, label: l10n.guests, keyboardType: TextInputType.number),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.eventDate),
                    subtitle: Text(start.toIso8601String().split('T').first),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheet,
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
                    onPressed: () => Navigator.pop(sheet, true),
                  ),
                ],
              );
            },
          ),
        );
      },
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
