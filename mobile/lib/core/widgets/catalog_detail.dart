import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/localized.dart';
import 'favorite_toggle.dart';
import 'json_title.dart';
import 'location_map_card.dart';
import 'property_card.dart';
import 'zaya_chrome.dart';

class CatalogDetailView extends StatelessWidget {
  const CatalogDetailView({
    super.key,
    required this.raw,
    required this.resourceType,
    required this.resourceId,
    this.extras = const [],
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.enableFavorite = true,
  });

  final Map<String, dynamic> raw;
  final String resourceType;
  final String resourceId;
  final List<Widget> extras;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool enableFavorite;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final urls = catalogImageUrls(raw);
    final title = catalogTitle(raw, locale);
    final city = catalogSubtitle(raw);
    final price = catalogPrice(raw);
    final rating = raw['ratingAvg'];
    final reviews = raw['ratingCount'];
    final description = localized(raw['description'], locale);
    final map = LocationMapCard.maybe(raw, label: city);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  if (enableFavorite) FavoriteToggleButton(resourceType: resourceType, resourceId: resourceId),
                ],
                expandedHeight: 280,
                flexibleSpace: FlexibleSpaceBar(
                  background: HeroGallery(urls: urls, height: 280),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList.list(
                  children: [
                    Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24)),
                    const SizedBox(height: 8),
                    if (city.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18, color: AppTheme.blue),
                          const SizedBox(width: 4),
                          Text(city, style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    if (rating != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '$rating · ${reviews ?? 0}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      JsonTitle(raw['description'], style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    for (final extra in extras) ...[
                      const SizedBox(height: 16),
                      extra,
                    ],
                    if (map != null) ...[
                      const SizedBox(height: 16),
                      map,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (onPrimary != null)
          StickyCtaBar(
            price: price,
            secondaryLabel: secondaryLabel,
            onSecondary: onSecondary,
            primaryLabel: primaryLabel ?? '',
            onPrimary: onPrimary!,
          ),
      ],
    );
  }
}
