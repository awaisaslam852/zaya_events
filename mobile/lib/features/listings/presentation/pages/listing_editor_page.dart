import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../uploads/presentation/upload_service.dart';
import '../cubit/listings_cubit.dart';

class ListingEditorPage extends StatefulWidget {
  const ListingEditorPage({super.key, this.id});
  final String? id;

  @override
  State<ListingEditorPage> createState() => _ListingEditorPageState();
}

class _ListingEditorPageState extends State<ListingEditorPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();
  final _price = TextEditingController(text: '2500');
  final List<Map<String, dynamic>> _categories = [];
  String? _categoryId;
  bool _loadingCats = true;
  bool _saving = false;
  bool _hydrated = false;
  String? _catError;
  final List<String> _gallery = [];
  bool _uploadingPhotos = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _city.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final result = await sl<ApiClient>().get<List<Map<String, dynamic>>>(
      '/service-categories',
      query: {'pageSize': 50},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) => setState(() {
        _loadingCats = false;
        _catError = failure.message;
      }),
      (items) => setState(() {
        _categories
          ..clear()
          ..addAll(items);
        _loadingCats = false;
        _categoryId ??= items.isEmpty ? null : items.first['id']?.toString();
      }),
    );
  }

  void _hydrate(Map<String, dynamic> detail) {
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    final locale = Localizations.localeOf(context).languageCode;
    _title.text = localized(detail['title'], locale);
    _description.text = localized(detail['description'], locale);
    _city.text = detail['city']?.toString() ?? '';
    _price.text = detail['startingPrice']?.toString() ?? '0';
    _categoryId = detail['categoryId']?.toString() ?? _categoryId;
    _gallery
      ..clear()
      ..addAll(catalogImageUrls(detail));
  }

  Future<void> _save(BuildContext context, ListingsCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _categoryId == null || _categoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requiredFields)));
      return;
    }
    setState(() => _saving = true);
    final description = _description.text.trim().isEmpty ? title : _description.text.trim();
    final error = await cubit.save(
      id: widget.id,
      body: {
        'categoryId': _categoryId,
        'title': catalogText(title),
        'description': catalogText(description),
        'city': _city.text.trim().isEmpty ? 'Dubai' : _city.text.trim(),
        'country': 'AE',
        'startingPrice': num.tryParse(_price.text.trim()) ?? 0,
        'currency': 'AED',
        'isPublished': true,
        if (_gallery.isNotEmpty) 'coverKey': _gallery.first,
        'galleryKeys': _gallery,
        'packages': <Map<String, dynamic>>[],
        'customFieldValues': <String, dynamic>{},
      },
    );
    if (!context.mounted) {
      return;
    }
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
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
        folder: 'listings',
      );
      uploaded.fold((failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      }, (result) {
        final url = result.url.isNotEmpty ? result.url : result.key;
        if (url.isNotEmpty) {
          _gallery.add(url);
        }
      });
    }
    if (mounted) {
      setState(() => _uploadingPhotos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (_) {
        final cubit = sl<ListingsCubit>();
        final id = widget.id;
        if (id != null) {
          cubit.loadOne(id);
        }
        return cubit;
      },
      child: BlocListener<ListingsCubit, ListingsState>(
        listener: (context, state) {
          final detail = state.detail;
          if (detail != null) {
            _hydrate(detail);
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(widget.id == null ? l10n.createListing : l10n.listings)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ZayaSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.createListing, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(l10n.languageHint, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    const SizedBox(height: 16),
                    if (_loadingCats)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_catError != null)
                      Text(_catError!, style: TextStyle(color: Theme.of(context).colorScheme.error))
                    else
                      DropdownButtonFormField<String>(
                        key: ValueKey(_categoryId ?? 'none'),
                        initialValue: _categories.any((c) => c['id']?.toString() == _categoryId) ? _categoryId : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.category,
                          prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.navy),
                        ),
                        items: [
                          for (final category in _categories)
                            DropdownMenuItem(
                              value: category['id']?.toString(),
                              child: Text(localized(category['name'], locale)),
                            ),
                        ],
                        onChanged: (value) => setState(() => _categoryId = value),
                      ),
                    const SizedBox(height: 12),
                    ZayaTextField(controller: _title, label: l10n.listingTitle, icon: Icons.title),
                    const SizedBox(height: 12),
                    ZayaTextField(
                      controller: _description,
                      label: l10n.listingDescription,
                      icon: Icons.notes_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    ZayaTextField(controller: _city, label: l10n.city, icon: Icons.location_city_outlined),
                    const SizedBox(height: 12),
                    ZayaTextField(
                      controller: _price,
                      label: l10n.startingPrice,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.photos, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(l10n.photosHint, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploadingPhotos ? null : _pickPhotos,
                      icon: _uploadingPhotos
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(l10n.addPhotos),
                    ),
                    if (_gallery.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CatalogGallery(urls: List<String>.from(_gallery)),
                    ],
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) => ZayaPrimaryButton(
                        label: l10n.save,
                        busy: _saving,
                        icon: Icons.save_outlined,
                        onPressed: () => _save(context, context.read<ListingsCubit>()),
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
