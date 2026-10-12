import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/vendor_dashboard_cubit.dart';

class VendorEarningsPage extends StatelessWidget {
  const VendorEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.earnings)),
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            final bookings = (state.earnings?['bookings'] as List?) ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ZayaSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.earnings, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        state.earnings?['totals']?.toString() ?? '0',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: AppTheme.navy),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final raw in bookings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ZayaSectionCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDCEBFA),
                          child: Icon(Icons.receipt_long, color: AppTheme.navy),
                        ),
                        title: Text(Map<String, dynamic>.from(raw as Map)['bookingNumber']?.toString() ?? ''),
                        subtitle: Text(Map<String, dynamic>.from(raw)['totalAmount']?.toString() ?? ''),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
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
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.reviews)),
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            final listings = (state.reviews?['listings'] as List?) ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: listings
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ZayaSectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFF4CC),
                            child: Icon(Icons.star, color: AppTheme.navy),
                          ),
                          title: JsonTitle(Map<String, dynamic>.from(e as Map)['title']),
                          subtitle: Text(
                            '${Map<String, dynamic>.from(e)['ratingAvg']} (${Map<String, dynamic>.from(e)['ratingCount']})',
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class VendorBusinessProfilePage extends StatelessWidget {
  const VendorBusinessProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.vendorProfile)),
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ZayaSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.navy,
                        child: Icon(Icons.storefront, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      JsonTitle(state.me?['businessName'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      JsonTitle(state.me?['description']),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18, color: AppTheme.navy),
                          const SizedBox(width: 6),
                          Text(state.me?['city']?.toString() ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
