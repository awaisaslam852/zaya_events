import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/flights_cubit.dart';
import '../cubit/flights_state.dart';

class FlightsListPage extends StatelessWidget {
  const FlightsListPage({super.key, this.embedded = false});
  final bool embedded;

  static Map<String, dynamic> _defaultQuery() {
    final date = DateTime.now().add(const Duration(days: 21)).toIso8601String().split('T').first;
    return {'origin': 'DXB', 'destination': 'LHR', 'date': date};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<FlightsCubit>()..load(query: _defaultQuery()),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.flights)),
        body: const _FlightsSearchBody(),
      ),
    );
  }
}

class _FlightsSearchBody extends StatefulWidget {
  const _FlightsSearchBody();

  @override
  State<_FlightsSearchBody> createState() => _FlightsSearchBodyState();
}

class _FlightsSearchBodyState extends State<_FlightsSearchBody> {
  late final TextEditingController _origin;
  late final TextEditingController _destination;
  DateTime _date = DateTime.now().add(const Duration(days: 21));

  @override
  void initState() {
    super.initState();
    _origin = TextEditingController(text: 'DXB');
    _destination = TextEditingController(text: 'LHR');
  }

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _search() {
    context.read<FlightsCubit>().load(query: {
      'origin': _origin.text.trim().toUpperCase(),
      'destination': _destination.text.trim().toUpperCase(),
      'date': _date.toIso8601String().split('T').first,
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
              Row(
                children: [
                  Expanded(child: ZayaTextField(controller: _origin, label: l10n.origin)),
                  const SizedBox(width: 8),
                  Expanded(child: ZayaTextField(controller: _destination, label: l10n.destination)),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.departDate),
                subtitle: Text(_date.toIso8601String().split('T').first),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
              ),
              ZayaPrimaryButton(label: l10n.searchFlights, icon: Icons.flight_takeoff, onPressed: _search),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<FlightsCubit, FlightsState>(
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
                    final title = item.raw['flightNumber'] ?? item.raw['title'] ?? item.raw['name'] ?? item.id;
                    final route = '${item.raw['origin'] ?? ''} → ${item.raw['destination'] ?? ''}';
                    final price = item.raw['priceAmount'];
                    return ListTile(
                      title: JsonTitle(title),
                      subtitle: Text('$route${price != null ? ' · $price ${item.raw['currency'] ?? 'AED'}' : ''}'),
                      onTap: () => context.push('/flights/${item.id}'),
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
