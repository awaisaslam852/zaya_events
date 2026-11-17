import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerPaymentsPage extends StatefulWidget {
  const CustomerPaymentsPage({super.key});

  @override
  State<CustomerPaymentsPage> createState() => _CustomerPaymentsPageState();
}

class _CustomerPaymentsPageState extends State<CustomerPaymentsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await sl<ApiClient>().get<List<Map<String, dynamic>>>(
      '/payments',
      query: {'pageSize': 50},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (items) => setState(() {
        _loading = false;
        _items = items;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenSync(
      topics: const [AppRefreshTopic.payments, AppRefreshTopic.bookings],
      onRefresh: (_) => _load(silent: true),
      child: Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            showBack: true,
            eyebrow: l10n.paymentHistory,
            title: l10n.paymentHistory,
            subtitle: l10n.paymentsSubtitle,
          ),
          Expanded(
            child: AsyncBody(
              loading: _loading,
              error: _error,
              empty: _items.isEmpty,
              emptyIcon: Icons.payments_outlined,
              emptyTitle: l10n.noPaymentsYet,
              emptyMessage: l10n.noPaymentsHint,
              onRetry: _load,
              child: RefreshIndicator(
                color: AppTheme.navy,
                onRefresh: () => _load(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final row = _items[index];
                    final booking = row['booking'];
                    final bookingId = row['bookingId']?.toString() ?? (booking is Map ? booking['id']?.toString() : null);
                    final kind = row['kind']?.toString() ?? l10n.paymentHistory;
                    final status = row['status']?.toString() ?? '';
                    final time = relativeTimeLabel(l10n, row['createdAt'] ?? row['paidAt']);
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: bookingId == null ? null : () => context.push('/bookings/$bookingId'),
                        borderRadius: BorderRadius.circular(18),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.line),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppTheme.priceWash,
                                  child: Icon(Icons.payments_outlined, color: AppTheme.navy),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(kind, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text(
                                        [status, if (time.isNotEmpty) time].join(' · '),
                                        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(row['amount'], row['currency']?.toString() ?? 'AED'),
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(label: status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
