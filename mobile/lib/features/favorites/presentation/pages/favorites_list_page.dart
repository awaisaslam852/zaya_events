import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/favorites_item.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

const _filters = <String?>[null, 'VENUE', 'VENDOR', 'LISTING', 'CAR', 'ACCOMMODATION', 'HONEYMOON', 'HOTEL'];

class FavoritesListPage extends StatelessWidget {
  const FavoritesListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.favorites],
        onRefresh: (context) => context.read<FavoritesCubit>().load(silent: true),
        child: const _FavoritesView(),
      ),
    );
  }
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            eyebrow: l10n.favorites,
            title: l10n.favoritesHeadline,
            subtitle: l10n.favoritesSubtitle,
          ),
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              if (state.items.isEmpty && !state.loading) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final value = _filters[index];
                    return FilterPill(
                      label: value == null ? l10n.allFilter : favoriteTypeLabel(l10n, value),
                      selected: _type == value,
                      onTap: () => setState(() => _type = value),
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                final items = _type == null
                    ? state.items
                    : state.items.where((item) => item.raw['resourceType']?.toString() == _type).toList();
                return AsyncBody(
                  loading: state.loading,
                  error: state.error,
                  empty: items.isEmpty,
                  emptyIcon: Icons.favorite_outline,
                  emptyTitle: l10n.noFavoritesYet,
                  emptyMessage: l10n.noFavoritesHint,
                  emptyActionLabel: l10n.browseToSave,
                  onEmptyAction: () => context.go('/customer/venues'),
                  onRetry: () => context.read<FavoritesCubit>().load(),
                  child: RefreshIndicator(
                    color: AppTheme.navy,
                    onRefresh: () => context.read<FavoritesCubit>().load(silent: true),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _FavoriteCard(item: items[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item});
  final FavoritesItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final type = item.raw['resourceType']?.toString();
    final image = catalogImageUrl(item.raw);
    final city = [
      item.raw['city'],
      item.raw['country'],
    ].where((part) => part != null && part.toString().isNotEmpty).join(' · ');
    final destination = favoriteDestination(item.raw);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: destination == null
            ? null
            : () async {
                await context.push(destination);
                if (context.mounted) {
                  context.read<FavoritesCubit>().load(silent: true);
                }
              },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: image == null
                        ? ColoredBox(
                            color: favoriteTypeWash(type),
                            child: Icon(favoriteTypeIcon(type), color: AppTheme.navy, size: 32),
                          )
                        : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: favoriteTypeWash(type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          favoriteTypeLabel(l10n, type),
                          style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localized(item.raw['name'] ?? item.raw['title'] ?? item.raw['businessName'] ?? item.id, locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.ink),
                      ),
                      if (city.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.removeFavorite,
                  onPressed: () async {
                    final error = await context.read<FavoritesCubit>().removeItem(item);
                    if (context.mounted && error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                  icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
