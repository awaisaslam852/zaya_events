import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
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
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<HotelsCubit>()..load(query: defaultQuery()),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.hotels)),
        body: const _HotelsSearchBody(),
      ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ZayaTextField(controller: _city, label: l10n.city, icon: Icons.location_city_outlined),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.checkIn),
                subtitle: Text(_checkIn.toIso8601String().split('T').first),
                onTap: () => _pick(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.checkOut),
                subtitle: Text(_checkOut.toIso8601String().split('T').first),
                onTap: () => _pick(false),
              ),
              ZayaPrimaryButton(label: l10n.search, icon: Icons.hotel_outlined, onPressed: _search),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<HotelsCubit, HotelsState>(
            builder: (context, state) {
              return AsyncBody(
                loading: state.loading,
                error: state.error,
                empty: state.items.isEmpty,
                onRetry: _search,
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final title = item.raw['title'] ?? item.raw['name'] ?? item.raw['businessName'] ?? item.id;
                    return ListTile(
                      title: JsonTitle(title),
                      subtitle: Text(item.raw['city']?.toString() ?? item.raw['status']?.toString() ?? ''),
                      onTap: () => context.push('/hotels/${item.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
