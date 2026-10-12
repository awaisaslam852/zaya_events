import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/listings_cubit.dart';

class VendorListingsPage extends StatelessWidget {
  const VendorListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<ListingsCubit>()..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(
              eyebrow: l10n.listings,
              title: 'Your catalog',
              subtitle: 'Create an offer customers can book.',
              trailing: FilledButton.icon(
                onPressed: () async {
                  final created = await context.push<bool>('/vendor/listing/new');
                  if (context.mounted && created == true) {
                    context.read<ListingsCubit>().load();
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createListing),
              ),
            ),
            Expanded(
              child: BlocBuilder<ListingsCubit, ListingsState>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.storefront_outlined,
                    emptyTitle: 'No listings yet',
                    emptyMessage: 'Add photography, catering, florals, or any service you sell.',
                    emptyActionLabel: l10n.createListing,
                    onEmptyAction: () async {
                      final created = await context.push<bool>('/vendor/listing/new');
                      if (context.mounted && created == true) {
                        context.read<ListingsCubit>().load();
                      }
                    },
                    onRetry: () => context.read<ListingsCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final raw = Map<String, dynamic>.from(state.items[index]);
                        return PropertyCard(
                          raw: raw,
                          onTap: () async {
                            await context.push('/vendor/listing/edit/${raw['id']}');
                            if (context.mounted) {
                              context.read<ListingsCubit>().load();
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
        },
      ),
    );
  }
}
