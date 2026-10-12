import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';

class VenuesDetailPage extends StatelessWidget {
  const VenuesDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VenuesCubit>()..loadOne(id),
      child: Scaffold(
        body: BlocBuilder<VenuesCubit, VenuesState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<VenuesCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'VENUE',
                      resourceId: item.id,
                      extras: [
                        if (item.raw['capacityMin'] != null || item.raw['capacityMax'] != null)
                          Text(
                            l10n.capacityGuests(
                              '${item.raw['capacityMin'] ?? '-'}',
                              '${item.raw['capacityMax'] ?? '-'}',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                      ],
                      primaryLabel: l10n.bookNow,
                      onPrimary: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.availabilitySent)));
                      },
                      secondaryLabel: l10n.inquire,
                      onSecondary: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.availabilitySent)));
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
