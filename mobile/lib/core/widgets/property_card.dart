import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/app_settings.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'zaya_dialogs.dart';
import '../utils/localized.dart';

String resolveMediaUrl(String url) {
  if (url.isEmpty) {
    return url;
  }
  if (!GetIt.I.isRegistered<AppConfig>()) {
    return url;
  }
  return GetIt.I<AppConfig>().rewriteMediaUrl(url);
}

String? catalogImageUrl(Map<String, dynamic> raw) {
  final urls = catalogImageUrls(raw);
  return urls.isEmpty ? null : urls.first;
}

List<String> catalogImageUrls(Map<String, dynamic> raw) {
  final urls = <String>[];
  void add(dynamic value) {
    final text = value?.toString() ?? '';
    final usable = text.startsWith('http') ||
        text.startsWith('/') ||
        text.startsWith('uploads/') ||
        text.contains('/');
    if (!usable) {
      return;
    }
    final resolved = resolveMediaUrl(text);
    if (resolved.isNotEmpty && !urls.contains(resolved)) {
      urls.add(resolved);
    }
  }

  add(raw['coverKey']);
  add(raw['logoKey']);
  final gallery = raw['galleryKeys'];
  if (gallery is List) {
    for (final item in gallery) {
      add(item);
    }
  }
  return urls;
}

Map<String, dynamic> catalogGalleryPayload(List<String> gallery) {
  return {
    'coverKey': gallery.isEmpty ? '' : gallery.first,
    'galleryKeys': List<String>.from(gallery),
  };
}

String catalogTitle(Map<String, dynamic> raw, String locale) {
  return localized(raw['title'] ?? raw['name'] ?? raw['businessName'] ?? raw['bookingNumber'] ?? raw['id'], locale);
}

String catalogSubtitle(Map<String, dynamic> raw) {
  return raw['city']?.toString() ??
      raw['destination']?.toString() ??
      raw['status']?.toString() ??
      raw['bookingNumber']?.toString() ??
      '';
}

bool catalogHasPublicRating(Map<String, dynamic> raw) {
  final rating = num.tryParse('${raw['ratingAvg'] ?? ''}');
  final reviewCount = int.tryParse('${raw['ratingCount'] ?? 0}') ?? 0;
  return reviewCount > 0 && rating != null && rating > 0;
}

String? catalogRatingLabel(Map<String, dynamic> raw) {
  if (!catalogHasPublicRating(raw)) {
    return null;
  }
  final rating = num.parse('${raw['ratingAvg']}');
  return rating.toStringAsFixed(rating % 1 == 0 ? 0 : 1);
}

num? catalogRawPrice(Map<String, dynamic> raw) {
  final direct = raw['startingPrice'] ?? raw['dailyRate'] ?? raw['nightlyRate'] ?? raw['priceAmount'] ?? raw['totalAmount'];
  final parsed = num.tryParse('$direct');
  if (parsed != null && parsed > 0) {
    return parsed;
  }
  final packages = raw['packages'];
  if (packages is! List) {
    return null;
  }
  num? lowest;
  for (final package in packages) {
    if (package is! Map) {
      continue;
    }
    final amount = num.tryParse('${package['priceAmount'] ?? ''}');
    if (amount == null || amount <= 0) {
      continue;
    }
    if (lowest == null || amount < lowest) {
      lowest = amount;
    }
  }
  return lowest;
}

String catalogPriceCurrency(Map<String, dynamic> raw) {
  final packages = raw['packages'];
  if (packages is List) {
    for (final package in packages) {
      if (package is Map && '${package['currency'] ?? ''}'.trim().isNotEmpty) {
        return package['currency'].toString();
      }
    }
  }
  return raw['currency']?.toString() ?? '';
}

bool catalogPriceIsPerGuest(Map<String, dynamic> raw) {
  if (raw['pricingModel']?.toString() == 'PER_GUEST') {
    return true;
  }
  final packages = raw['packages'];
  if (packages is! List) {
    return false;
  }
  for (final package in packages) {
    if (package is Map && package['pricingUnit']?.toString() == 'GUEST') {
      return true;
    }
  }
  return false;
}

String? catalogPrice(Map<String, dynamic> raw) {
  final number = catalogRawPrice(raw);
  if (number == null) {
    return null;
  }
  final currency = appCurrency(fallback: catalogPriceCurrency(raw));
  final amount = number.toStringAsFixed(number % 1 == 0 ? 0 : 0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]},',
      );
  final suffix = catalogPriceIsPerGuest(raw) ? ' / guest' : '';
  return '$currency $amount$suffix';
}

String? catalogGuestRange(Map<String, dynamic> raw) {
  final min = raw['capacityMin']?.toString();
  final max = raw['capacityMax']?.toString();
  if ((min == null || min.isEmpty) && (max == null || max.isEmpty)) {
    return null;
  }
  if (min != null && min.isNotEmpty && max != null && max.isNotEmpty) {
    return '$min–$max';
  }
  return min ?? max;
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.raw,
    required this.onTap,
    this.horizontal = false,
  });

  final Map<String, dynamic> raw;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final image = catalogImageUrl(raw);
    final rating = catalogRatingLabel(raw);
    final price = catalogPrice(raw);
    final guests = catalogGuestRange(raw);
    final seats = raw['seats']?.toString();
    final city = catalogSubtitle(raw);
    final imageHeight = horizontal ? 128.0 : 168.0;
    final radius = BorderRadius.circular(18);

    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: AppTheme.navy.withValues(alpha: 0.12),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: AppTheme.line),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image == null
                          ? const ColoredBox(
                              color: AppTheme.wash,
                              child: Icon(Icons.apartment, color: AppTheme.navy, size: 40),
                            )
                          : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover, width: double.infinity),
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x3300183D), Colors.transparent, Color(0x6600183D)],
                              stops: [0, 0.45, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.favorite_border, size: 16, color: AppTheme.navy),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: rating != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 13, color: AppTheme.yellow),
                                    const SizedBox(width: 3),
                                    Text(
                                      rating,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  l10n.justListed,
                                  style: const TextStyle(color: AppTheme.navy, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catalogTitle(raw, locale),
                      maxLines: horizontal ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.ink, height: 1.2),
                    ),
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: AppTheme.blue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.blue, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (guests != null || seats != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            guests != null ? Icons.groups_outlined : Icons.event_seat_outlined,
                            size: 15,
                            color: AppTheme.navy,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guests != null ? '$guests ${l10n.guests}' : '$seats ${l10n.vehicleSeats}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.ink),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.priceWash,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.fromPrice(price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogGallery extends StatelessWidget {
  const CatalogGallery({super.key, required this.urls, this.height = 220});

  final List<String> urls;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final url = urls[index];
          return GestureDetector(
            onTap: () => showCatalogLightbox(context, urls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: url, width: 280, height: height, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}

class CatalogGalleryEditor extends StatelessWidget {
  const CatalogGalleryEditor({super.key, required this.urls, required this.onChanged});

  final List<String> urls;
  final ValueChanged<List<String>> onChanged;

  Future<void> _remove(BuildContext context, int index) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showZayaConfirm(
      context,
      title: l10n.removePhotoTitle,
      message: l10n.removePhotoMessage,
      confirmLabel: l10n.remove,
      icon: Icons.hide_image_outlined,
    );
    if (!ok) {
      return;
    }
    final next = List<String>.from(urls)..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    const size = 168.0;
    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = urls[index];
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => showCatalogLightbox(context, urls, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                    ),
                  ),
                ),
                if (index == 0)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.coverPhoto,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: const Color(0xFFB42318),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _remove(context, index),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
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

void showCatalogLightbox(BuildContext context, List<String> urls, int initialIndex) {
  showZayaLightbox(context, urls, initialIndex);
}

class CatalogFeed extends StatelessWidget {
  const CatalogFeed({
    super.key,
    required this.itemCount,
    required this.rawAt,
    required this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final Map<String, dynamic> Function(int index) rawAt;
  final void Function(int index) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => PropertyCard(raw: rawAt(index), onTap: () => onTap(index)),
    );
  }
}
