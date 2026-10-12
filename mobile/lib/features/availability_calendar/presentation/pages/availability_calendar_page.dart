import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../domain/availability_usecases.dart';
import '../../../../l10n/app_localizations.dart';

class AvailabilityCubit extends Cubit<List<DateTime>> {
  AvailabilityCubit(this._list) : super(const []);
  final ListAvailability _list;

  Future<void> load() async {
    final result = await _list();
    result.fold((_) => emit(const []), (page) {
      final days = page.items
          .map((e) => DateTime.tryParse(e['startAt']?.toString() ?? e['date']?.toString() ?? ''))
          .whereType<DateTime>()
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList();
      emit(days);
    });
  }
}

class AvailabilityCalendarPage extends StatefulWidget {
  const AvailabilityCalendarPage({super.key});

  @override
  State<AvailabilityCalendarPage> createState() => _AvailabilityCalendarPageState();
}

class _AvailabilityCalendarPageState extends State<AvailabilityCalendarPage> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => AvailabilityCubit(sl<ListAvailability>())..load(),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(showBack: true, eyebrow: l10n.calendar, title: 'Availability', subtitle: 'Yellow dots mark booked or blocked days.'),
            Expanded(
              child: BlocBuilder<AvailabilityCubit, List<DateTime>>(
                builder: (context, days) {
                  final onSelected = days.where((d) => isSameDay(d, _selected)).toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      ZayaSectionCard(
                        child: TableCalendar<DateTime>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2035, 12, 31),
                          focusedDay: _focused,
                          selectedDayPredicate: (day) => isSameDay(day, _selected),
                          eventLoader: (day) => days.where((d) => isSameDay(d, day)).toList(),
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selected = selected;
                              _focused = focused;
                            });
                          },
                          onPageChanged: (focused) => _focused = focused,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.navy),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(color: AppTheme.blue.withValues(alpha: 0.85), shape: BoxShape.circle),
                            selectedDecoration: const BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
                            markerDecoration: const BoxDecoration(color: AppTheme.yellow, shape: BoxShape.circle),
                            weekendTextStyle: const TextStyle(color: Color(0xFFB45309)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        onSelected.isEmpty ? 'No bookings on this date' : '${onSelected.length} booking(s) on this date',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selected.day} ${_month(_selected.month)} ${_selected.year}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}
