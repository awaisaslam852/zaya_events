import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'property_card.dart';

class ZayaSectionHeader extends StatelessWidget {
  const ZayaSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class ZayaSearchField extends StatelessWidget {
  const ZayaSearchField({super.key, required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.navy),
              const SizedBox(width: 10),
              Expanded(child: Text(hint, style: const TextStyle(color: AppTheme.muted, fontSize: 15))),
              const Icon(Icons.tune, color: AppTheme.navy),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.blue),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class StickyCtaBar extends StatelessWidget {
  const StickyCtaBar({
    super.key,
    this.price,
    this.secondaryLabel,
    this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String? price;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: AppTheme.navy.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              if (price != null)
                Expanded(
                  child: Text(
                    price!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.navy),
                  ),
                )
              else
                const Spacer(),
              if (secondaryLabel != null && onSecondary != null) ...[
                OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
                const SizedBox(width: 8),
              ],
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogRail extends StatelessWidget {
  const CatalogRail({
    super.key,
    required this.itemCount,
    required this.rawAt,
    required this.onTap,
    this.loading = false,
    this.emptyLabel,
  });

  final int itemCount;
  final Map<String, dynamic> Function(int index) rawAt;
  final void Function(int index) onTap;
  final bool loading;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
    }
    if (itemCount == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(emptyLabel ?? '', style: const TextStyle(color: AppTheme.muted)),
      );
    }
    return SizedBox(
      height: 292,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 236,
            child: PropertyCard(raw: rawAt(index), horizontal: true, onTap: () => onTap(index)),
          );
        },
      ),
    );
  }
}

class HeroGallery extends StatefulWidget {
  const HeroGallery({super.key, required this.urls, this.height = 280});

  final List<String> urls;
  final double height;

  @override
  State<HeroGallery> createState() => _HeroGalleryState();
}

class _HeroGalleryState extends State<HeroGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return Container(height: widget.height, color: AppTheme.navy, child: const Icon(Icons.photo, color: Colors.white54, size: 48));
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: widget.urls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => showCatalogLightbox(context, widget.urls, index),
                child: CachedNetworkImage(imageUrl: widget.urls[index], fit: BoxFit.cover, width: double.infinity),
              );
            },
          ),
        ),
        if (widget.urls.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.urls.length; i++)
                  Container(
                    width: i == _index ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
