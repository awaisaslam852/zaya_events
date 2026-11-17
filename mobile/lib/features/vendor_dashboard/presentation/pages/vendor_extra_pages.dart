import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_settings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/vendor_dashboard_cubit.dart';
import '../vendor_dashboard_metrics.dart';

class VendorEarningsPage extends StatelessWidget {
  const VendorEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.vendorDashboard, AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<VendorDashboardCubit>().load(silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        appBar: AppBar(title: Text(l10n.earnings)),
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            final metrics = VendorDashboardMetrics(
              state.earnings,
              state.me,
              state.reviews,
            );
            final totals = state.earnings?['totals'];
            final deposits = totals is Map
                ? num.tryParse(totals['deposits']?.toString() ?? '') ?? 0
                : 0;
            final balances = totals is Map
                ? num.tryParse(totals['balances']?.toString() ?? '') ?? 0
                : 0;
            final currency = appCurrency(fallback: metrics.currency);
            final bookings = metrics.bookings;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ZayaSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.paymentHistory,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$currency ${_money(metrics.totalAmount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MoneyStat(
                              label: l10n.deposits,
                              value: '$currency ${_money(deposits)}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MoneyStat(
                              label: l10n.remaining,
                              value: '$currency ${_money(balances)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bookings,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (bookings.isEmpty)
                  ZayaSectionCard(
                    child: Text(
                      l10n.noBookingsYet,
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                  )
                else
                  for (final booking in bookings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            final id = booking['id']?.toString();
                            if (id != null && id.isNotEmpty) {
                              context.push('/bookings/$id');
                            }
                          },
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFDCEBFA),
                            child: Icon(
                              Icons.receipt_long,
                              color: AppTheme.navy,
                            ),
                          ),
                          title: Text(
                            booking['bookingNumber']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            [
                              '$currency ${_money(num.tryParse(booking['totalAmount']?.toString() ?? '') ?? 0)}',
                              _date(context, booking['createdAt']?.toString()),
                            ].where((part) => part.isNotEmpty).join(' · '),
                          ),
                          trailing: StatusBadge(
                            label: booking['status']?.toString() ?? '',
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  static String _money(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match[1]},',
        );
  }

  static String _date(BuildContext context, String? raw) {
    final parsed = DateTime.tryParse(raw ?? '');
    if (parsed == null) {
      return '';
    }
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(parsed.toLocal());
  }
}

class _MoneyStat extends StatelessWidget {
  const _MoneyStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.wash,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class VendorReviewsPage extends StatelessWidget {
  const VendorReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..loadReviews(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.vendorDashboard, AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<VendorDashboardCubit>().loadReviews(),
        child: Scaffold(
        appBar: AppBar(title: Text(l10n.reviews)),
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            final items = (state.reviews?['items'] as List?) ?? [];
            final listings = (state.reviews?['listings'] as List?) ?? [];
            final venues = (state.reviews?['venues'] as List?) ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (items.isEmpty)
                  ZayaSectionCard(
                    child: Text(l10n.noReviewsYet, style: const TextStyle(color: AppTheme.muted)),
                  ),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ZayaSectionCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF4CC),
                          child: Icon(Icons.star, color: AppTheme.navy),
                        ),
                        title: Text(
                          Map<String, dynamic>.from(item as Map)['authorName']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          localized(
                            Map<String, dynamic>.from(item)['body'],
                            Localizations.localeOf(context).languageCode,
                          ),
                        ),
                        trailing: Text(
                          '${Map<String, dynamic>.from(item)['rating']}/5',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
                        ),
                      ),
                    ),
                  ),
                for (final e in [...venues, ...listings])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ZayaSectionCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF4CC),
                          child: Icon(Icons.star, color: AppTheme.navy),
                        ),
                        title: JsonTitle(
                          Map<String, dynamic>.from(e as Map)['title'] ??
                              Map<String, dynamic>.from(e)['name'],
                        ),
                        subtitle: Text(
                          '${Map<String, dynamic>.from(e)['ratingAvg']} (${Map<String, dynamic>.from(e)['ratingCount']})',
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}

class VendorBusinessProfilePage extends StatefulWidget {
  const VendorBusinessProfilePage({super.key});

  @override
  State<VendorBusinessProfilePage> createState() =>
      _VendorBusinessProfilePageState();
}

class _VendorBusinessProfilePageState extends State<VendorBusinessProfilePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _legal = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _city.dispose();
    _phone.dispose();
    _website.dispose();
    _legal.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, dynamic> me) {
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    final locale = Localizations.localeOf(context).languageCode;
    _name.text = localized(me['businessName'], locale);
    _description.text = localized(me['description'], locale);
    _city.text = me['city']?.toString() ?? '';
    _phone.text = me['phone']?.toString() ?? '';
    _website.text = me['website']?.toString() ?? '';
    _legal.text = me['legalName']?.toString() ?? '';
  }

  Future<void> _save(VendorDashboardCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requiredFields)));
      return;
    }
    setState(() => _saving = true);
    final error = await cubit.saveProfile({
      'businessName': catalogText(name),
      'description': catalogText(
        _description.text.trim().isEmpty ? name : _description.text.trim(),
      ),
      'city': _city.text.trim().isEmpty ? null : _city.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'website': _website.text.trim().isEmpty ? null : _website.text.trim(),
      'legalName': _legal.text.trim().isEmpty ? null : _legal.text.trim(),
    });
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? l10n.saveSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..load(),
      child: BlocListener<VendorDashboardCubit, VendorDashboardState>(
        listener: (context, state) {
          final me = state.me;
          if (me != null) {
            _hydrate(me);
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.vendorProfile)),
          body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ZayaSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ZayaTextField(
                          controller: _name,
                          label: l10n.businessName,
                          icon: Icons.storefront_outlined,
                        ),
                        const SizedBox(height: 12),
                        ZayaTextField(
                          controller: _description,
                          label: l10n.listingDescription,
                          icon: Icons.notes_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        ZayaTextField(
                          controller: _city,
                          label: l10n.city,
                          icon: Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 12),
                        ZayaTextField(
                          controller: _phone,
                          label: l10n.phone,
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 12),
                        ZayaTextField(
                          controller: _website,
                          label: l10n.website,
                          icon: Icons.language,
                        ),
                        const SizedBox(height: 12),
                        ZayaTextField(
                          controller: _legal,
                          label: l10n.legalName,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 20),
                        ZayaPrimaryButton(
                          label: l10n.save,
                          busy: _saving,
                          icon: Icons.save_outlined,
                          onPressed: () =>
                              _save(context.read<VendorDashboardCubit>()),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
