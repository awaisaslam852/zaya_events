import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/booking_requests_usecases.dart';

class BookingRequestsCubit extends Cubit<({bool loading, String? error, List<Map<String, dynamic>> items})> {
  BookingRequestsCubit(this._list, this._transition) : super((loading: false, error: null, items: const []));

  final ListBookingRequests _list;
  final TransitionBooking _transition;

  Future<void> load() async {
    emit((loading: true, error: null, items: state.items));
    final result = await _list();
    result.fold(
      (f) => emit((loading: false, error: f.message, items: state.items)),
      (page) => emit((loading: false, error: null, items: page.items)),
    );
  }

  Future<String?> act(String id, String action) async {
    final result = await _transition(id, action);
    final error = result.fold((f) => f.message, (_) => null);
    if (error != null) {
      return error;
    }
    await load();
    return null;
  }
}

class BookingRequestsPage extends StatelessWidget {
  const BookingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => BookingRequestsCubit(sl(), sl())..load(),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(eyebrow: l10n.requests, title: 'Booking inbox', subtitle: 'Confirm or decline incoming enquiries.'),
            Expanded(
              child: BlocBuilder<BookingRequestsCubit, ({bool loading, String? error, List<Map<String, dynamic>> items})>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.inbox_outlined,
                    emptyTitle: 'No requests yet',
                    emptyMessage: 'When customers enquire, they will appear here.',
                    onRetry: () => context.read<BookingRequestsCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final status = item['status']?.toString() ?? '';
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFFDCEBFA),
                                      child: Icon(Icons.receipt_long, color: AppTheme.navy),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['bookingNumber']?.toString() ?? item['id'].toString(),
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                          ),
                                          Text(
                                            item['type']?.toString() ?? '',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(label: status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${item['currency'] ?? 'AED'} ${item['totalAmount'] ?? '—'}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 18),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final error = await context.read<BookingRequestsCubit>().act(item['id'].toString(), 'reject');
                                          if (error != null && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                          }
                                        },
                                        child: Text(l10n.reject),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () async {
                                          final error = await context.read<BookingRequestsCubit>().act(item['id'].toString(), 'confirm');
                                          if (error != null && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                          }
                                        },
                                        child: Text(l10n.confirm),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
