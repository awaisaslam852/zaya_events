import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesListPage extends StatelessWidget {
  const FavoritesListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<FavoritesCubit>()..load(),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.favorites)),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<FavoritesCubit>().load(),
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final title = item.raw['name'] ?? item.raw['title'] ?? item.raw['businessName'] ?? item.id;
                  return ListTile(
                    title: JsonTitle(title),
                    subtitle: Text(item.raw['city']?.toString() ?? item.raw['status']?.toString() ?? ''),
                    onTap: () {
                      final type = item.raw['resourceType']?.toString();
                      final rid = item.raw['providerRef']?.toString() ?? item.raw['resourceId']?.toString() ?? item.id;
                      final path = switch (type) {
                        'VENUE' => '/venues/$rid',
                        'LISTING' => '/vendors_browse/$rid',
                        'VENDOR' => '/vendors_browse/$rid',
                        'CAR' => '/cars/$rid',
                        'ACCOMMODATION' => '/accommodations/$rid',
                        'HOTEL' => '/hotels/$rid',
                        'HONEYMOON' => '/honeymoon/$rid',
                        _ => '/favorites/${item.id}',
                      };
                      context.push(path);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
