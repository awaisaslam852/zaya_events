import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_settings.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/localized.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/zaya_fields.dart';
import '../../../l10n/app_localizations.dart';
import '../../uploads/presentation/upload_service.dart';
import '../vendor_catalog_cubit.dart';
import '../vendor_catalog_kind.dart';

class VendorProductEditorPage extends StatefulWidget {
  const VendorProductEditorPage({super.key, required this.kind, this.id});

  final VendorCatalogKind kind;
  final String? id;

  @override
  State<VendorProductEditorPage> createState() =>
      _VendorProductEditorPageState();
}

class _VendorProductEditorPageState extends State<VendorProductEditorPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();
  final _price = TextEditingController(text: '2500');
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController(text: '${DateTime.now().year}');
  final _seats = TextEditingController(text: '4');
  final _capacityMin = TextEditingController(text: '50');
  final _capacityMax = TextEditingController(text: '300');
  final _bedrooms = TextEditingController(text: '2');
  final _bathrooms = TextEditingController(text: '2');
  final _maxGuests = TextEditingController(text: '6');
  final _nights = TextEditingController(text: '7');
  final _destination = TextEditingController();
  final _address = TextEditingController();
  String _transmission = 'AUTOMATIC';
  String _stayType = 'VILLA';
  String _pricingModel = 'HYBRID';
  bool _published = true;
  bool _saving = false;
  bool _hydrated = false;
  bool _uploadingPhotos = false;
  final List<String> _gallery = [];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _city.dispose();
    _price.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _seats.dispose();
    _capacityMin.dispose();
    _capacityMax.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    _maxGuests.dispose();
    _nights.dispose();
    _destination.dispose();
    _address.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, dynamic> detail) {
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    final locale = Localizations.localeOf(context).languageCode;
    _title.text = localized(detail['title'] ?? detail['name'], locale);
    _description.text = localized(detail['description'], locale);
    _city.text = detail['city']?.toString() ?? '';
    final loaded = catalogRawPrice(detail);
    _price.text = loaded == null ? '' : (loaded % 1 == 0 ? loaded.toStringAsFixed(0) : loaded.toString());
    _pricingModel = detail['pricingModel']?.toString() ?? _pricingModel;
    _make.text = detail['make']?.toString() ?? '';
    _model.text = detail['model']?.toString() ?? '';
    _year.text = detail['year']?.toString() ?? _year.text;
    _seats.text = detail['seats']?.toString() ?? _seats.text;
    _capacityMin.text = detail['capacityMin']?.toString() ?? _capacityMin.text;
    _capacityMax.text = detail['capacityMax']?.toString() ?? _capacityMax.text;
    _bedrooms.text = detail['bedrooms']?.toString() ?? _bedrooms.text;
    _bathrooms.text = detail['bathrooms']?.toString() ?? _bathrooms.text;
    _maxGuests.text = detail['maxGuests']?.toString() ?? _maxGuests.text;
    _nights.text = detail['nights']?.toString() ?? _nights.text;
    _destination.text = localized(detail['destination'], locale);
    _address.text = localized(detail['address'], locale);
    _transmission = detail['transmission']?.toString() ?? _transmission;
    _stayType = detail['type']?.toString() ?? _stayType;
    _published = detail['isPublished'] != false;
    _gallery
      ..clear()
      ..addAll(catalogImageUrls(detail));
  }

  Map<String, dynamic> _body() {
    final title = _title.text.trim();
    final description = _description.text.trim().isEmpty
        ? title
        : _description.text.trim();
    final city = _city.text.trim();
    final price = num.tryParse(_price.text.trim()) ?? 0;
    final currency = appCurrency();
    final named = catalogText(title);
    final described = catalogText(description);
    final common = <String, dynamic>{
      ...catalogGalleryPayload(_gallery),
      'isPublished': _published,
      'currency': currency,
    };
    switch (widget.kind) {
      case VendorCatalogKind.all:
      case VendorCatalogKind.listing:
        return {
          ...common,
          'title': named,
          'description': described,
          'city': city,
          'startingPrice': price,
        };
      case VendorCatalogKind.venue:
        return {
          ...common,
          'name': named,
          'description': described,
          'address': catalogText(
            _address.text.trim().isEmpty ? city : _address.text.trim(),
          ),
          'city': city,
          'latitude': 25.2048,
          'longitude': 55.2708,
          'capacityMin': int.tryParse(_capacityMin.text.trim()) ?? 50,
          'capacityMax': int.tryParse(_capacityMax.text.trim()) ?? 300,
          'startingPrice': price,
          'pricingModel': _pricingModel,
          'amenities': <String>[],
        };
      case VendorCatalogKind.car:
        return {
          ...common,
          'name': named,
          'description': described,
          'make': _make.text.trim().isEmpty ? title : _make.text.trim(),
          'model': _model.text.trim().isEmpty ? title : _model.text.trim(),
          'year': int.tryParse(_year.text.trim()) ?? DateTime.now().year,
          'seats': int.tryParse(_seats.text.trim()) ?? 4,
          'transmission': _transmission,
          'dailyRate': price,
        };
      case VendorCatalogKind.stay:
        return {
          ...common,
          'name': named,
          'description': described,
          'type': _stayType,
          'address': catalogText(
            _address.text.trim().isEmpty ? city : _address.text.trim(),
          ),
          'city': city,
          'maxGuests': int.tryParse(_maxGuests.text.trim()) ?? 6,
          'bedrooms': int.tryParse(_bedrooms.text.trim()) ?? 2,
          'bathrooms': int.tryParse(_bathrooms.text.trim()) ?? 2,
          'nightlyRate': price,
          'amenities': <String>[],
        };
      case VendorCatalogKind.honeymoon:
        return {
          ...common,
          'name': named,
          'description': described,
          'destination': catalogText(
            _destination.text.trim().isEmpty ? title : _destination.text.trim(),
          ),
          'nights': int.tryParse(_nights.text.trim()) ?? 7,
          'priceAmount': price,
          'inclusions': <String>[],
        };
    }
  }

  Future<void> _save(VendorCatalogCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final needsCity =
        widget.kind == VendorCatalogKind.venue ||
        widget.kind == VendorCatalogKind.stay ||
        widget.kind == VendorCatalogKind.listing;
    if (_title.text.trim().isEmpty || (needsCity && _city.text.trim().isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requiredFields)));
      return;
    }
    setState(() => _saving = true);
    final error = await cubit.save(
      kind: widget.kind,
      id: widget.id,
      body: _body(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
    context.pop(true);
  }

  Future<void> _pickPhotos() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (files.isEmpty) {
      return;
    }
    setState(() => _uploadingPhotos = true);
    for (final file in files) {
      final uploaded = await sl<UploadService>().upload(
        filePath: file.path,
        filename: file.name,
        folder: widget.kind.uploadFolder,
      );
      uploaded.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          }
        },
        (result) {
          final url = result.url.isNotEmpty ? result.url : result.key;
          if (url.isNotEmpty) {
            _gallery.add(url);
          }
        },
      );
    }
    if (mounted) {
      setState(() => _uploadingPhotos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) {
        final cubit = sl<VendorCatalogCubit>();
        final id = widget.id;
        if (id != null) {
          cubit.loadOne(widget.kind, id);
        }
        return cubit;
      },
      child: BlocListener<VendorCatalogCubit, VendorCatalogState>(
        listener: (context, state) {
          final detail = state.detail;
          if (detail != null) {
            _hydrate(detail);
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.id == null ? l10n.addProduct : l10n.editProduct),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ZayaSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ZayaTextField(
                      controller: _title,
                      label: l10n.listingTitle,
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 12),
                    ZayaTextField(
                      controller: _description,
                      label: l10n.listingDescription,
                      icon: Icons.notes_outlined,
                      maxLines: 4,
                    ),
                    if (widget.kind == VendorCatalogKind.venue ||
                        widget.kind == VendorCatalogKind.stay) ...[
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _city,
                        label: l10n.city,
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _address,
                        label: l10n.address,
                        icon: Icons.place_outlined,
                      ),
                    ],
                    if (widget.kind == VendorCatalogKind.venue) ...[
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _capacityMin,
                        label: l10n.capacityMin,
                        icon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _capacityMax,
                        label: l10n.capacityMax,
                        icon: Icons.groups,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (widget.kind == VendorCatalogKind.car) ...[
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _make,
                        label: l10n.vehicleMake,
                        icon: Icons.directions_car_outlined,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _model,
                        label: l10n.vehicleModel,
                        icon: Icons.directions_car_filled_outlined,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _year,
                        label: l10n.vehicleYear,
                        icon: Icons.event,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _seats,
                        label: l10n.vehicleSeats,
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _transmission,
                        decoration: InputDecoration(
                          labelText: l10n.transmission,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'AUTOMATIC',
                            child: Text(l10n.automatic),
                          ),
                          DropdownMenuItem(
                            value: 'MANUAL',
                            child: Text(l10n.manual),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _transmission = value ?? _transmission,
                        ),
                      ),
                    ],
                    if (widget.kind == VendorCatalogKind.stay) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _stayType,
                        decoration: InputDecoration(labelText: l10n.category),
                        items: const [
                          DropdownMenuItem(
                            value: 'VILLA',
                            child: Text('Villa'),
                          ),
                          DropdownMenuItem(
                            value: 'APARTMENT',
                            child: Text('Apartment'),
                          ),
                          DropdownMenuItem(
                            value: 'HOTEL_ROOM',
                            child: Text('Hotel room'),
                          ),
                          DropdownMenuItem(
                            value: 'RESORT',
                            child: Text('Resort'),
                          ),
                          DropdownMenuItem(
                            value: 'CHALET',
                            child: Text('Chalet'),
                          ),
                          DropdownMenuItem(
                            value: 'BUNGALOW',
                            child: Text('Bungalow'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _stayType = value ?? _stayType),
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _maxGuests,
                        label: l10n.guests,
                        icon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _bedrooms,
                        label: l10n.bedrooms,
                        icon: Icons.bed_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _bathrooms,
                        label: l10n.bathrooms,
                        icon: Icons.bathtub_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (widget.kind == VendorCatalogKind.honeymoon) ...[
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _destination,
                        label: l10n.tripDestination,
                        icon: Icons.public,
                      ),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _nights,
                        label: l10n.nightsCount,
                        icon: Icons.nights_stay_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 12),
                    ZayaTextField(
                      controller: _price,
                      label: widget.kind == VendorCatalogKind.car
                          ? l10n.dailyRate
                          : widget.kind == VendorCatalogKind.stay
                          ? l10n.nightlyRate
                          : widget.kind == VendorCatalogKind.venue && _pricingModel == 'PER_GUEST'
                          ? l10n.pricePerGuest
                          : l10n.startingPrice,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    if (widget.kind == VendorCatalogKind.venue) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _pricingModel,
                        decoration: InputDecoration(labelText: l10n.pricingModel),
                        items: [
                          DropdownMenuItem(value: 'HIRE', child: Text(l10n.pricingHire)),
                          DropdownMenuItem(value: 'PER_GUEST', child: Text(l10n.pricingPerGuest)),
                          DropdownMenuItem(value: 'HYBRID', child: Text(l10n.pricingHybrid)),
                        ],
                        onChanged: (value) => setState(() => _pricingModel = value ?? _pricingModel),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_published ? l10n.publish : l10n.unpublish),
                      value: _published,
                      onChanged: (value) => setState(() => _published = value),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.photos,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.photosHint, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploadingPhotos ? null : _pickPhotos,
                      icon: _uploadingPhotos
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(l10n.addPhotos),
                    ),
                    if (_gallery.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CatalogGalleryEditor(
                        urls: List<String>.from(_gallery),
                        onChanged: (next) => setState(() {
                          _gallery
                            ..clear()
                            ..addAll(next);
                        }),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) => ZayaPrimaryButton(
                        label: l10n.save,
                        busy: _saving,
                        icon: Icons.save_outlined,
                        onPressed: () =>
                            _save(context.read<VendorCatalogCubit>()),
                      ),
                    ),
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
