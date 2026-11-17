import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
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
    return BlocProvider(
      create: (_) => sl<FlightsCubit>()..load(query: _defaultQuery()),
      child: const _FlightsSearchBody(),
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
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(showBack: true, eyebrow: l10n.travel, title: l10n.flights, subtitle: l10n.flightsSubtitle),
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
                        Row(
                          children: [
                            Expanded(child: ZayaTextField(controller: _origin, label: l10n.origin, icon: Icons.flight_takeoff)),
                            const SizedBox(width: 8),
                            Expanded(child: ZayaTextField(controller: _destination, label: l10n.destination, icon: Icons.flight_land)),
                          ],
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.wash,
                            child: Icon(Icons.calendar_month_outlined, color: AppTheme.navy),
                          ),
                          title: Text(l10n.departDate),
                          subtitle: Text(_date.toIso8601String().split('T').first),
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
                ),
                Expanded(
                  child: BlocBuilder<FlightsCubit, FlightsState>(
                    builder: (context, state) {
                      return AsyncBody(
                        loading: state.loading,
                        error: state.error,
                        empty: state.items.isEmpty,
                        emptyIcon: Icons.flight_takeoff_outlined,
                        emptyTitle: l10n.empty,
                        emptyMessage: l10n.flightsSubtitle,
                        onRetry: _search,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final origin = item.raw['origin']?.toString() ?? '';
                            final destination = item.raw['destination']?.toString() ?? '';
                            final number = item.raw['flightNumber']?.toString() ?? item.id;
                            final depart = parseApiDate(item.raw['departureAt']);
                            final currency = item.raw['currency']?.toString() ?? 'AED';
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () => context.push('/flights/${item.id}'),
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.line),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(number, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
                                            const Spacer(),
                                            if (item.raw['priceAmount'] != null)
                                              Text(
                                                formatMoney(item.raw['priceAmount'], currency),
                                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Text(origin, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                                            const SizedBox(width: 10),
                                            const Expanded(
                                              child: Icon(Icons.flight_takeoff, color: AppTheme.blue),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(destination, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                                          ],
                                        ),
                                        if (depart != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            depart.toString().split('.').first.replaceFirst('T', ' '),
                                            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
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
