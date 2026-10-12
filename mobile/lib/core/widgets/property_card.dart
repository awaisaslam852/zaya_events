import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/app_settings.dart';
import '../theme/app_theme.dart';
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

String? catalogPrice(Map<String, dynamic> raw) {
  final value =
      raw['startingPrice'] ?? raw['dailyRate'] ?? raw['nightlyRate'] ?? raw['priceAmount'] ?? raw['totalAmount'];
  if (value == null) {
    return null;
  }
  final currency = appCurrency(fallback: raw['currency']?.toString());
  final number = num.tryParse(value.toString());
  final amount = number == null
      ? value.toString()
      : number.toStringAsFixed(number % 1 == 0 ? 0 : 0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (match) => '${match[1]},',
          );
  return '$currency $amount';
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
    final locale = Localizations.localeOf(context).languageCode;
    final image = catalogImageUrl(raw);
    final rating = raw['ratingAvg'];
    final price = catalogPrice(raw);
    final imageHeight = horizontal ? 140.0 : 168.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
                child: Stack(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: image == null
                          ? const ColoredBox(
                              color: AppTheme.wash,
                              child: Icon(Icons.apartment, color: AppTheme.navy, size: 40),
                            )
                          : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover, width: double.infinity),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade700),
                      ),
                    ),
                    if (rating != null)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '$rating',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catalogTitle(raw, locale),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 16, color: AppTheme.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            catalogSubtitle(raw),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (price != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.priceWash,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(price, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
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

void showCatalogLightbox(BuildContext context, List<String> urls, int initialIndex) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.black,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: CachedNetworkImage(imageUrl: urls[index], fit: BoxFit.contain),
              );
            },
          ),
        ),
      );
    },
  );
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
