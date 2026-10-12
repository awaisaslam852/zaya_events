import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';

class VenuesListPage extends StatelessWidget {
  const VenuesListPage({super.key, this.embedded = false, this.cubit});
  final bool embedded;
  final VenuesCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => cubit ?? (sl<VenuesCubit>()..load()),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.venues)),
        body: BlocBuilder<VenuesCubit, VenuesState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<VenuesCubit>().load(),
              child: CatalogFeed(
                itemCount: state.items.length,
                rawAt: (index) => state.items[index].raw,
                onTap: (index) => context.push('/venues/${state.items[index].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
