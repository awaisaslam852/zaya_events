import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/events_usecases.dart';

const _venueTypes = ['Hall', 'Garden', 'Beach', 'Hotel', 'Villa', 'Outdoor', 'Restaurant'];

class EventEditorPage extends StatefulWidget {
  const EventEditorPage({super.key, this.id});
  final String? id;

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final _title = TextEditingController();
  final _city = TextEditingController(text: 'Dubai');
  final _guests = TextEditingController(text: '120');
  final _budgetMin = TextEditingController();
  final _budgetMax = TextEditingController();
  final _notes = TextEditingController();
  final List<Map<String, dynamic>> _categories = [];
  String? _categoryId;
  String? _venueType;
  DateTime _date = DateTime.now().add(const Duration(days: 45));
  DateTime? _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 0);
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _title.dispose();
    _city.dispose();
    _guests.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final result = await sl<ApiClient>().get<List<Map<String, dynamic>>>(
      '/event-categories',
      query: {'pageSize': 50},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
    if (!mounted) {
      return;
    }
    await result.fold(
      (failure) async => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (items) async {
        _categories
          ..clear()
          ..addAll(items.where((e) => e['isActive'] != false));
        _categoryId = _categories.isEmpty ? null : _categories.first['id']?.toString();
        if (_editing) {
          await _loadEvent();
        } else {
          setState(() => _loading = false);
        }
      },
    );
  }

  Future<void> _loadEvent() async {
    final result = await sl<GetEvents>()(widget.id!);
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (item) {
        final raw = item.raw;
        final locale = Localizations.localeOf(context).languageCode;
        _title.text = localized(raw['title'], locale);
        _city.text = raw['city']?.toString() ?? 'Dubai';
        _guests.text = '${raw['guestCount'] ?? ''}';
        _budgetMin.text = raw['budgetMin']?.toString() ?? '';
        _budgetMax.text = raw['budgetMax']?.toString() ?? '';
        _notes.text = localized(raw['notes'], locale);
        _venueType = raw['preferredVenueType']?.toString();
        _categoryId = raw['categoryId']?.toString() ?? _categoryId;
        final start = DateTime.tryParse(raw['eventDate']?.toString() ?? '');
        if (start != null) {
          _date = start.toLocal();
          _startTime = TimeOfDay(hour: start.toLocal().hour, minute: start.toLocal().minute);
        }
        final end = DateTime.tryParse(raw['endDate']?.toString() ?? '');
        if (end != null) {
          _endDate = end.toLocal();
          _endTime = TimeOfDay(hour: end.toLocal().hour, minute: end.toLocal().minute);
        }
        setState(() => _loading = false);
      },
    );
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requiredFields)));
      return;
    }
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'categoryId': _categoryId,
      'title': catalogText(title),
      'description': catalogText(title),
      'eventDate': _combine(_date, _startTime).toIso8601String(),
      'guestCount': int.tryParse(_guests.text.trim()) ?? 50,
      'city': _city.text.trim().isEmpty ? 'Dubai' : _city.text.trim(),
      'country': 'AE',
      'currency': 'AED',
      if (_endDate != null) 'endDate': _combine(_endDate!, _endTime).toIso8601String(),
      if (_budgetMin.text.trim().isNotEmpty) 'budgetMin': num.tryParse(_budgetMin.text.trim()),
      if (_budgetMax.text.trim().isNotEmpty) 'budgetMax': num.tryParse(_budgetMax.text.trim()),
      if (_notes.text.trim().isNotEmpty) 'notes': catalogText(_notes.text.trim()),
      if (_venueType != null) 'preferredVenueType': _venueType,
      if (!_editing) 'status': 'planning',
    };
    final result = _editing ? await sl<UpdateEvent>()(widget.id!, body) : await sl<CreateEvent>()(body);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
        context.pop(true);
      },
    );
  }

  Future<void> _pickDate({required bool end}) async {
    final initial = end ? (_endDate ?? _date) : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (end) {
          _endDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool end}) async {
    final picked = await showTimePicker(context: context, initialTime: end ? _endTime : _startTime);
    if (picked != null) {
      setState(() {
        if (end) {
          _endTime = picked;
        } else {
          _startTime = picked;
        }
      });
    }
  }

  String _fmtDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.editEvent : l10n.createEvent)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ZayaSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Event details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 6),
                Text('One title is enough. Switch app language from Profile.', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
                else ...[
                  Text(l10n.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in _categories)
                        ChoiceChip(
                          label: Text(localized(category['name'], locale)),
                          selected: category['id']?.toString() == _categoryId,
                          selectedColor: AppTheme.yellow,
                          onSelected: (_) => setState(() => _categoryId = category['id']?.toString()),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ZayaTextField(controller: _title, label: l10n.eventTitle, icon: Icons.title),
                const SizedBox(height: 12),
                ZayaTextField(controller: _city, label: l10n.city, icon: Icons.location_city_outlined),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _guests,
                  label: l10n.guests,
                  icon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCEBFA),
                    child: Icon(Icons.event, color: AppTheme.navy),
                  ),
                  title: Text(l10n.eventDate),
                  subtitle: Text('${_fmtDate(_date)} · ${_startTime.format(context)}'),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    await _pickDate(end: false);
                    if (context.mounted) {
                      await _pickTime(end: false);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCEBFA),
                    child: Icon(Icons.event_available, color: AppTheme.navy),
                  ),
                  title: Text(l10n.eventEnd),
                  subtitle: Text(
                    _endDate == null ? l10n.optional : '${_fmtDate(_endDate!)} · ${_endTime.format(context)}',
                  ),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    await _pickDate(end: true);
                    if (context.mounted) {
                      await _pickTime(end: true);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(l10n.preferredVenue, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in _venueTypes)
                      ChoiceChip(
                        label: Text(type),
                        selected: _venueType == type,
                        selectedColor: AppTheme.yellow,
                        onSelected: (_) => setState(() => _venueType = type),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _budgetMin,
                  label: l10n.budgetMin,
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _budgetMax,
                  label: l10n.budgetMax,
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _notes,
                  label: l10n.notes,
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ZayaPrimaryButton(
                  label: l10n.save,
                  busy: _saving,
                  icon: Icons.check_circle_outline,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
