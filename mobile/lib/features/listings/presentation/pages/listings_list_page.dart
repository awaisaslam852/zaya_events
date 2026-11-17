import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/browse_country.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/listings_cubit.dart';

class ListingsListPage extends StatelessWidget {
  const ListingsListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<ListingsCubit>()..load(query: browseQuery()),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.services)),
        body: BlocBuilder<ListingsCubit, ListingsState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<ListingsCubit>().load(query: browseQuery()),
              child: CatalogFeed(
                itemCount: state.items.length,
                rawAt: (index) => state.items[index],
                onTap: (index) => context.push('/listings/${state.items[index]['id']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
