import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/session_role.dart';
import '../di/injection.dart';
import '../network/api_client.dart';
import '../sync/app_refresh.dart';
import '../utils/localized.dart';
import '../../features/cart/cart_cubit.dart';
import '../../l10n/app_localizations.dart';
import 'zaya_dialogs.dart';
import 'zaya_fields.dart';

enum CatalogRequestMode { book, inquire, visit, addToCart }

class CatalogRequest {
  static Future<void> open(
    BuildContext context, {
    required CatalogRequestMode mode,
    required String resourceType,
    required String resourceId,
    bool needsEndDate = false,
    bool needsGuests = false,
  }) {
    if (isVendorSession(context)) {
      return Future.value();
    }
    final l10n = AppLocalizations.of(context);
    final title = switch (mode) {
      CatalogRequestMode.book => l10n.bookNow,
      CatalogRequestMode.inquire => l10n.inquire,
      CatalogRequestMode.visit => l10n.requestVisit,
      CatalogRequestMode.addToCart => l10n.addToCart,
    };
    return showZayaSheet<void>(
      context: context,
      child: ZayaSheetScaffold(
        title: title,
        child: _CatalogRequestForm(
          mode: mode,
          resourceType: resourceType,
          resourceId: resourceId,
          needsEndDate: needsEndDate,
          needsGuests: needsGuests,
        ),
      ),
    );
  }
}

class _CatalogRequestForm extends StatefulWidget {
  const _CatalogRequestForm({
    required this.mode,
    required this.resourceType,
    required this.resourceId,
    required this.needsEndDate,
    required this.needsGuests,
  });

  final CatalogRequestMode mode;
  final String resourceType;
  final String resourceId;
  final bool needsEndDate;
  final bool needsGuests;

  @override
  State<_CatalogRequestForm> createState() => _CatalogRequestFormState();
}

class _CatalogRequestFormState extends State<_CatalogRequestForm> {
  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _guests;
  final _notes = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now().add(const Duration(days: 21));
    _end = _start.add(const Duration(days: 1));
    final hotelOrStay = widget.resourceType == 'HOTEL' || widget.resourceType == 'ACCOMMODATION';
    _guests = TextEditingController(text: hotelOrStay ? '2' : '50');
  }

  @override
  void dispose() {
    _guests.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(bool end) async {
    final current = end ? _end : _start;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (end) {
        _end = DateTime(picked.year, picked.month, picked.day, 12);
        if (!_end.isAfter(_start)) {
          _start = _end.subtract(const Duration(days: 1));
        }
      } else {
        _start = DateTime(picked.year, picked.month, picked.day, 12);
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(days: 1));
        }
      }
    });
  }

  Map<String, String>? _notesBody() {
    final text = _notes.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return catalogText(text);
  }

  int? _guestCount() {
    if (!widget.needsGuests) {
      return null;
    }
    return int.tryParse(_guests.text.trim());
  }

  String _iso(DateTime value) => value.toUtc().toIso8601String();

  (String, Map<String, dynamic>) _request() {
    final notes = _notesBody();
    final guests = _guestCount();
    final type = widget.resourceType;
    final id = widget.resourceId;
    if (widget.mode == CatalogRequestMode.addToCart) {
      return (
        '/cart',
        {
          'type': type,
          'resourceId': id,
          'startAt': _iso(_start),
          if (widget.needsEndDate) 'endAt': _iso(_end),
          if (guests != null) 'guestCount': guests,
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (widget.mode == CatalogRequestMode.visit) {
      return (
        '/venue-visits',
        {
          'venueId': id,
          'scheduledAt': _iso(_start),
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (type == 'HOTEL') {
      return (
        '/hotels/$id/book',
        {
          'checkIn': _iso(_start),
          'checkOut': _iso(_end),
          'rooms': 1,
          if (guests != null) 'guests': guests,
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (type == 'CAR') {
      return (
        '/cars/$id/book',
        {
          'startAt': _iso(_start),
          'endAt': _iso(_end),
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (type == 'ACCOMMODATION') {
      return (
        '/accommodations/$id/book',
        {
          'startAt': _iso(_start),
          'endAt': _iso(_end),
          if (guests != null) 'guestCount': guests,
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (type == 'HONEYMOON') {
      return (
        '/honeymoon/$id/inquire',
        {
          'startAt': _iso(_start),
          if (widget.needsEndDate) 'endAt': _iso(_end),
          if (notes != null) 'notes': notes,
        },
      );
    }
    if (type == 'VENUE' && widget.mode == CatalogRequestMode.inquire) {
      return (
        '/venues/$id/inquire',
        {
          'startAt': _iso(_start),
          if (widget.needsEndDate) 'endAt': _iso(_end),
          if (guests != null) 'guestCount': guests,
          if (notes != null) 'notes': notes,
        },
      );
    }
    final bookingType = switch (type) {
      'VENUE' => 'VENUE',
      'LISTING' => 'LISTING',
      'CAR' => 'CAR',
      'ACCOMMODATION' => 'ACCOMMODATION',
      'HONEYMOON' => 'HONEYMOON',
      _ => type,
    };
    final path = widget.mode == CatalogRequestMode.inquire ? '/bookings/inquire' : '/bookings';
    return (
      path,
      {
        'type': bookingType,
        if (type == 'VENUE') 'venueId': id,
        if (type == 'LISTING') 'listingId': id,
        if (type == 'CAR') 'carId': id,
        if (type == 'ACCOMMODATION') 'accommodationId': id,
        if (type == 'HONEYMOON') 'honeymoonId': id,
        'startAt': _iso(_start),
        if (widget.needsEndDate) 'endAt': _iso(_end),
        if (guests != null) 'guestCount': guests,
        if (notes != null) 'notes': notes,
      },
    );
  }

  String? _resultId(Map<String, dynamic> data) {
    final direct = data['id']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    final bookingId = data['bookingId']?.toString();
    if (bookingId != null && bookingId.isNotEmpty) {
      return bookingId;
    }
    final nested = data['booking'];
    if (nested is Map && nested['id'] != null) {
      return nested['id'].toString();
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final request = _request();
    final result = await sl<ApiClient>().post<Map<String, dynamic>>(
      request.$1,
      data: request.$2,
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
      }),
      (data) {
        final id = _resultId(data);
        final router = GoRouter.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context);
        Navigator.pop(context);
        if (widget.mode == CatalogRequestMode.addToCart) {
          sl<CartCubit>().load();
          AppRefresh.instance.afterCart();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              zayaSnackBar(
                l10n.addedToCart,
                kind: ZayaSnackKind.success,
                action: SnackBarAction(label: l10n.cart, onPressed: () => router.push('/customer/cart')),
              ),
            );
          return;
        }
        if (widget.mode == CatalogRequestMode.visit) {
          AppRefresh.instance.afterVisit();
        } else {
          AppRefresh.instance.afterBooking();
        }
        if (id == null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(zayaSnackBar(l10n.availabilitySent, kind: ZayaSnackKind.success));
          return;
        }
        router.push(widget.mode == CatalogRequestMode.visit ? '/venue_visits/$id' : '/bookings/$id');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(widget.mode == CatalogRequestMode.visit ? l10n.eventDate : l10n.eventDate),
            subtitle: Text(_start.toIso8601String().split('T').first),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () => _pick(false),
          ),
          if (widget.needsEndDate)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.checkOut),
              subtitle: Text(_end.toIso8601String().split('T').first),
              trailing: const Icon(Icons.event_outlined),
              onTap: () => _pick(true),
            ),
          if (widget.needsGuests) ...[
            const SizedBox(height: 8),
            ZayaTextField(
              controller: _guests,
              label: l10n.guests,
              keyboardType: TextInputType.number,
              icon: Icons.groups_outlined,
            ),
          ],
          const SizedBox(height: 8),
          ZayaTextField(
            controller: _notes,
            label: l10n.notes,
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          ZayaPrimaryButton(
            label: widget.mode == CatalogRequestMode.addToCart ? l10n.addToCart : l10n.sendRequest,
            icon: widget.mode == CatalogRequestMode.addToCart ? Icons.shopping_bag_outlined : Icons.send_outlined,
            busy: _busy,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
