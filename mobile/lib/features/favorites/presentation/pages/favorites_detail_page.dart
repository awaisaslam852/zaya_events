import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesDetailPage extends StatelessWidget {
  const FavoritesDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<FavoritesCubit>()..loadOne(id),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.favorites)),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<FavoritesCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        JsonTitle(item.raw['title'] ?? item.raw['name'] ?? item.raw['businessName'], style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(item.raw['city']?.toString() ?? ''),
                        const SizedBox(height: 12),
                        JsonTitle(item.raw['description']),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
