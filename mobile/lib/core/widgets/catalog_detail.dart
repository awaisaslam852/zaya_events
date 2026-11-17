import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/vendor_catalog/vendor_catalog_kind.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session_role.dart';
import '../theme/app_theme.dart';
import '../utils/customer_hub.dart';
import '../utils/localized.dart';
import '../../features/bookings/presentation/widgets/review_sheet.dart';
import 'favorite_toggle.dart';
import 'location_map_card.dart';
import 'property_card.dart';
import 'zaya_chrome.dart';

bool catalogShouldShowDescription(String description, String title) {
  return description.trim().isNotEmpty && description.trim().toLowerCase() != title.trim().toLowerCase();
}

String catalogAmenityLabel(dynamic item, String locale) {
  final text = item is Map ? localized(item, locale) : item.toString();
  return text
      .trim()
      .replaceAll(RegExp(r'[-_]+'), ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part.length == 1 ? part.toUpperCase() : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class CatalogQuickAction {
  const CatalogQuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class CatalogDetailView extends StatelessWidget {
  const CatalogDetailView({
    super.key,
    required this.raw,
    required this.resourceType,
    required this.resourceId,
    this.extras = const [],
    this.quickActions = const [],
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.onChat,
    this.enableFavorite = true,
    this.isVendor,
    this.ownedByViewer,
  });

  final Map<String, dynamic> raw;
  final String resourceType;
  final String resourceId;
  final List<Widget> extras;
  final List<CatalogQuickAction> quickActions;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback? onChat;
  final bool enableFavorite;
  final bool? isVendor;
  final bool? ownedByViewer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final urls = catalogImageUrls(raw);
    final title = catalogTitle(raw, locale);
    final city = catalogSubtitle(raw);
    final address = localized(raw['address'], locale);
    final price = catalogPrice(raw);
    final description = localized(raw['description'], locale);
    final showDescription = catalogShouldShowDescription(description, title);
    final map = LocationMapCard.maybe(raw, label: address.isNotEmpty ? address : city);
    final rating = num.tryParse('${raw['ratingAvg'] ?? ''}');
    final reviewCount = int.tryParse('${raw['ratingCount'] ?? 0}') ?? 0;
    final hasReviews = catalogHasPublicRating(raw);
    final amenities = (raw['amenities'] is List)
        ? (raw['amenities'] as List)
            .map((item) => catalogAmenityLabel(item, locale))
            .where((item) => item.isNotEmpty)
            .toList()
        : const <String>[];
    final capacityMin = raw['capacityMin']?.toString();
    final capacityMax = raw['capacityMax']?.toString();
    final hasCapacity = (capacityMin != null && capacityMin.isNotEmpty) || (capacityMax != null && capacityMax.isNotEmpty);
    final vendor = isVendor ?? isVendorSession(context);
    final owned = ownedByViewer ??
        catalogOwnedByViewer(
          raw,
          userId: sessionUserId(context),
          vendorId: sessionVendorId(context),
        );
    final customerActions = !vendor;
    final editPath = vendor && owned ? vendorEditPathForResource(resourceType, resourceId) : null;
    final publicReviews = catalogPublicReviews(raw);
    final actions = [
      if (customerActions && onChat != null)
        CatalogQuickAction(
          icon: Icons.chat_bubble_outline,
          label: l10n.messageVendor,
          onTap: onChat!,
        ),
      if (customerActions) ...quickActions,
    ];

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                automaticallyImplyLeading: false,
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: const _GlassBackButton(),
                actions: [
                  if (enableFavorite && customerActions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _GlassCircle(
                        child: FavoriteToggleButton(
                          resourceType: resourceType,
                          resourceId: resourceId,
                          light: true,
                        ),
                      ),
                    ),
                ],
                expandedHeight: 320,
                flexibleSpace: FlexibleSpaceBar(
                  background: HeroGallery(urls: urls, height: 320),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList.list(
                  children: [
                    _HeaderCard(
                      title: title,
                      city: city,
                      hasReviews: hasReviews,
                      rating: rating,
                      justListedLabel: l10n.justListed,
                      reviewsLabel: hasReviews ? l10n.reviewsCount('$reviewCount') : null,
                      fromLabel: price == null ? null : l10n.fromPrice(price),
                    ),
                    if (hasCapacity || amenities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _FactsRow(
                        capacityLabel: hasCapacity
                            ? l10n.capacityGuests(capacityMin ?? '–', capacityMax ?? '–')
                            : null,
                        amenities: amenities,
                      ),
                    ],
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _QuickActions(actions: actions),
                    ],
                    for (final extra in extras) ...[
                      const SizedBox(height: 12),
                      extra,
                    ],
                    if (showDescription) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: l10n.overview,
                        child: Text(
                          description,
                          style: const TextStyle(color: AppTheme.ink, height: 1.5, fontSize: 15),
                        ),
                      ),
                    ],
                    if (publicReviews.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: l10n.guestReviews,
                        child: Column(
                          children: [
                            for (var i = 0; i < publicReviews.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _PublicReviewTile(review: publicReviews[i], locale: locale),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (map != null) ...[
                      const SizedBox(height: 16),
                      Text(l10n.location, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.ink)),
                      const SizedBox(height: 10),
                      map,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (customerActions && onPrimary != null)
          StickyCtaBar(
            price: price,
            secondaryLabel: secondaryLabel,
            onSecondary: onSecondary,
            primaryLabel: primaryLabel ?? '',
            onPrimary: onPrimary!,
          )
        else if (editPath != null)
          StickyCtaBar(
            price: price,
            primaryLabel: l10n.editProduct,
            onPrimary: () => context.push(editPath),
          ),
      ],
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: _GlassCircle(
        child: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.city,
    required this.hasReviews,
    required this.rating,
    required this.justListedLabel,
    required this.reviewsLabel,
    required this.fromLabel,
  });

  final String title;
  final String city;
  final bool hasReviews;
  final num? rating;
  final String justListedLabel;
  final String? reviewsLabel;
  final String? fromLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink, height: 1.15)),
            if (city.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: AppTheme.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(city, style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (hasReviews)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating!.toStringAsFixed(rating! % 1 == 0 ? 0 : 1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(reviewsLabel ?? '', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.priceWash, borderRadius: BorderRadius.circular(10)),
                    child: Text(justListedLabel, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                if (fromLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4CC), borderRadius: BorderRadius.circular(10)),
                    child: Text(fromLabel!, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactsRow extends StatelessWidget {
  const _FactsRow({this.capacityLabel, required this.amenities});

  final String? capacityLabel;
  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (capacityLabel != null) _FactChip(icon: Icons.groups_outlined, label: capacityLabel!),
      for (final amenity in amenities.take(6)) _FactChip(icon: Icons.check_circle_outline, label: amenity),
    ];
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.navy),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.ink)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});
  final List<CatalogQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: actions[i].onTap,
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.line),
                    color: i == 0 ? const Color(0xFFFFF8E6) : AppTheme.wash.withValues(alpha: 0.55),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    child: Column(
                      children: [
                        Icon(actions[i].icon, color: AppTheme.navy),
                        const SizedBox(height: 8),
                        Text(
                          actions[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.navy, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.ink)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _PublicReviewTile extends StatelessWidget {
  const _PublicReviewTile({required this.review, required this.locale});
  final Map<String, dynamic> review;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final name = review['authorName']?.toString() ?? '';
    final comment = localized(review['body'], locale);
    final rating = num.tryParse('${review['rating'] ?? 0}') ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
            ),
            ReviewStars(rating: rating, size: 16),
          ],
        ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(comment, style: const TextStyle(height: 1.4, color: AppTheme.ink)),
        ],
      ],
    );
  }
}
