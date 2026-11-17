import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/hotels_cubit.dart';
import '../cubit/hotels_state.dart';

class HotelsListPage extends StatelessWidget {
  const HotelsListPage({super.key, this.embedded = false});
  final bool embedded;

  static Map<String, dynamic> defaultQuery() {
    final checkIn = DateTime.now().add(const Duration(days: 14));
    final checkOut = checkIn.add(const Duration(days: 3));
    return {
      'city': 'Dubai',
      'checkIn': checkIn.toIso8601String().split('T').first,
      'checkOut': checkOut.toIso8601String().split('T').first,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HotelsCubit>()..load(query: defaultQuery()),
      child: const _HotelsSearchBody(),
    );
  }
}

class _HotelsSearchBody extends StatefulWidget {
  const _HotelsSearchBody();

  @override
  State<_HotelsSearchBody> createState() => _HotelsSearchBodyState();
}

class _HotelsSearchBodyState extends State<_HotelsSearchBody> {
  late final TextEditingController _city;
  DateTime _checkIn = DateTime.now().add(const Duration(days: 14));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 17));

  @override
  void initState() {
    super.initState();
    _city = TextEditingController(text: 'Dubai');
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  void _search() {
    context.read<HotelsCubit>().load(query: {
      'city': _city.text.trim(),
      'checkIn': _checkIn.toIso8601String().split('T').first,
      'checkOut': _checkOut.toIso8601String().split('T').first,
    });
  }

  Future<void> _pick(bool checkIn) async {
    final initial = checkIn ? _checkIn : _checkOut;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (checkIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked.isAfter(_checkIn) ? picked : _checkIn.add(const Duration(days: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(showBack: true, eyebrow: l10n.travel, title: l10n.hotels, subtitle: l10n.hotelsSubtitle),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.line),
                    ),
                    child: Column(
                      children: [
                        ZayaTextField(controller: _city, label: l10n.city, icon: Icons.location_city_outlined),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.login, color: AppTheme.navy),
                          title: Text(l10n.checkIn),
                          subtitle: Text(_checkIn.toIso8601String().split('T').first),
                          onTap: () => _pick(true),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.nights_stay_outlined, color: AppTheme.navy),
                          title: Text(l10n.checkOut),
                          subtitle: Text(_checkOut.toIso8601String().split('T').first),
                          onTap: () => _pick(false),
                        ),
                        ZayaPrimaryButton(label: l10n.search, icon: Icons.hotel_outlined, onPressed: _search),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HotelsCubit, HotelsState>(
                    builder: (context, state) {
                      return AsyncBody(
                        loading: state.loading,
                        error: state.error,
                        empty: state.items.isEmpty,
                        emptyIcon: Icons.apartment_outlined,
                        emptyTitle: l10n.empty,
                        emptyMessage: l10n.hotelsSubtitle,
                        onRetry: _search,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final locale = Localizations.localeOf(context).languageCode;
                            final image = catalogImageUrl(item.raw);
                            final city = item.raw['city']?.toString() ?? '';
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () => context.push('/hotels/${item.id}'),
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.line),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                        child: SizedBox(
                                          width: 108,
                                          height: 108,
                                          child: image == null
                                              ? const ColoredBox(
                                                  color: AppTheme.wash,
                                                  child: Icon(Icons.apartment, color: AppTheme.navy, size: 32),
                                                )
                                              : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                localized(item.raw['title'] ?? item.raw['name'], locale),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                              ),
                                              if (city.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(city, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                                              ],
                                              if (item.raw['starRating'] != null) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  '★ ${item.raw['starRating']}',
                                                  style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
