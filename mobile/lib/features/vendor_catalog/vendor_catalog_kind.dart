import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

const catalogKindField = '_catalogKind';

enum VendorCatalogKind {
  all,
  listing,
  venue,
  car,
  stay,
  honeymoon;

  static List<VendorCatalogKind> get sellable =>
      values.where((kind) => kind != all).toList();

  bool get isAggregate => this == all;

  String get path => switch (this) {
        all => 'listings',
        listing => 'listings',
        venue => 'venues',
        car => 'cars',
        stay => 'accommodations',
        honeymoon => 'honeymoon',
      };

  String get uploadFolder => isAggregate ? listing.path : path;

  String get newPath => switch (this) {
        all => listing.newPath,
        listing => '/vendor/listing/new',
        venue => '/vendor/venues/new',
        car => '/vendor/cars/new',
        stay => '/vendor/stays/new',
        honeymoon => '/vendor/honeymoon/new',
      };

  String editPath(String id) => switch (this) {
        all => listing.editPath(id),
        listing => '/vendor/listing/edit/$id',
        venue => '/vendor/venues/edit/$id',
        car => '/vendor/cars/edit/$id',
        stay => '/vendor/stays/edit/$id',
        honeymoon => '/vendor/honeymoon/edit/$id',
      };

  IconData get icon => switch (this) {
        all => Icons.grid_view_rounded,
        listing => Icons.auto_awesome_outlined,
        venue => Icons.apartment_outlined,
        car => Icons.directions_car_outlined,
        stay => Icons.hotel_outlined,
        honeymoon => Icons.flight_takeoff_outlined,
      };

  String label(AppLocalizations l10n) => switch (this) {
        all => l10n.catalogAll,
        listing => l10n.services,
        venue => l10n.venues,
        car => l10n.cars,
        stay => l10n.accommodations,
        honeymoon => l10n.honeymoon,
      };

  static VendorCatalogKind? fromName(String? value) {
    for (final kind in VendorCatalogKind.values) {
      if (kind.name == value) {
        return kind;
      }
    }
    return null;
  }
}

String? vendorEditPathForResource(String resourceType, String id) {
  if (id.isEmpty) {
    return null;
  }
  return switch (resourceType.toUpperCase()) {
    'VENUE' => VendorCatalogKind.venue.editPath(id),
    'LISTING' => VendorCatalogKind.listing.editPath(id),
    'CAR' => VendorCatalogKind.car.editPath(id),
    'ACCOMMODATION' => VendorCatalogKind.stay.editPath(id),
    'HONEYMOON' => VendorCatalogKind.honeymoon.editPath(id),
    _ => null,
  };
}

VendorCatalogKind catalogKindOf(
  Map<String, dynamic> raw, [
  VendorCatalogKind fallback = VendorCatalogKind.listing,
]) {
  return VendorCatalogKind.fromName(raw[catalogKindField]?.toString()) ?? fallback;
}

Map<String, dynamic> withCatalogKind(
  Map<String, dynamic> item,
  VendorCatalogKind kind,
) {
  return {...item, catalogKindField: kind.name};
}
