import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

DateTime? parseApiDate(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text)?.toLocal();
}

int? eventDaysFromNow(dynamic eventDate) {
  final date = parseApiDate(eventDate);
  if (date == null) {
    return null;
  }
  final now = DateTime.now();
  final start = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  return start.difference(today).inDays;
}

String eventCountdownLabel(AppLocalizations l10n, dynamic eventDate) {
  final days = eventDaysFromNow(eventDate);
  if (days == null) {
    return '';
  }
  if (days == 0) {
    return l10n.eventToday;
  }
  if (days > 0) {
    return l10n.daysToGo('$days');
  }
  return l10n.daysAgoLabel('${-days}');
}

String relativeTimeLabel(AppLocalizations l10n, dynamic value) {
  final date = parseApiDate(value);
  if (date == null) {
    return '';
  }
  final delta = DateTime.now().difference(date);
  if (delta.inMinutes < 1) {
    return l10n.justNow;
  }
  if (delta.inMinutes < 60) {
    return l10n.minutesAgo('${delta.inMinutes}');
  }
  if (delta.inHours < 24) {
    return l10n.hoursAgo('${delta.inHours}');
  }
  if (delta.inHours < 48) {
    return l10n.today;
  }
  return l10n.daysAgoLabel('${delta.inDays}');
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool notificationUnread(Map<String, dynamic> raw) {
  final readAt = raw['readAt']?.toString() ?? '';
  return readAt.isEmpty;
}

Map<String, dynamic> notificationPayload(Map<String, dynamic> raw) {
  final data = raw['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return const <String, dynamic>{};
}

String? favoriteDestination(Map<String, dynamic> raw) {
  final type = raw['resourceType']?.toString();
  final rid = raw['providerRef']?.toString() ?? raw['resourceId']?.toString();
  if (rid == null || rid.isEmpty) {
    return null;
  }
  return switch (type) {
    'VENUE' => '/venues/$rid',
    'LISTING' => '/listings/$rid',
    'VENDOR' => '/vendors_browse/$rid',
    'CAR' => '/cars/$rid',
    'ACCOMMODATION' => '/accommodations/$rid',
    'HOTEL' => '/hotels/$rid',
    'HONEYMOON' => '/honeymoon/$rid',
    _ => null,
  };
}

String? notificationDestination(Map<String, dynamic> raw) {
  final payload = notificationPayload(raw);
  final bookingId = payload['bookingId']?.toString();
  final visitId = payload['visitId']?.toString();
  final conversationId = payload['conversationId']?.toString();
  if (bookingId != null && bookingId.isNotEmpty) {
    return '/bookings/$bookingId';
  }
  if (visitId != null && visitId.isNotEmpty) {
    return '/venue_visits/$visitId';
  }
  if (conversationId != null && conversationId.isNotEmpty) {
    return '/chat/$conversationId';
  }
  return null;
}

IconData favoriteTypeIcon(String? type) {
  return switch (type) {
    'VENUE' => Icons.apartment_outlined,
    'LISTING' => Icons.auto_awesome_outlined,
    'VENDOR' => Icons.storefront_outlined,
    'CAR' => Icons.directions_car_outlined,
    'ACCOMMODATION' => Icons.hotel_outlined,
    'HOTEL' => Icons.domain_outlined,
    'HONEYMOON' => Icons.favorite_outline,
    _ => Icons.bookmark_outline,
  };
}

Color favoriteTypeWash(String? type) {
  return switch (type) {
    'VENUE' => const Color(0xFFDCEBFA),
    'LISTING' => const Color(0xFFFFF1C2),
    'VENDOR' => const Color(0xFFE8F0FE),
    'CAR' => const Color(0xFFE3F6EA),
    'ACCOMMODATION' => const Color(0xFFEDE7F6),
    'HOTEL' => const Color(0xFFDCEBFA),
    'HONEYMOON' => const Color(0xFFFFE4EC),
    _ => const Color(0xFFDCEBFA),
  };
}

String favoriteTypeLabel(AppLocalizations l10n, String? type) {
  return switch (type) {
    'VENUE' => l10n.venues,
    'LISTING' => l10n.services,
    'VENDOR' => l10n.vendors,
    'CAR' => l10n.cars,
    'ACCOMMODATION' => l10n.accommodations,
    'HOTEL' => l10n.hotels,
    'HONEYMOON' => l10n.honeymoon,
    _ => l10n.favorites,
  };
}

String bookingTypeLabel(AppLocalizations l10n, String? type) {
  return switch (type) {
    'VENUE' => l10n.venues,
    'LISTING' => l10n.services,
    'CAR' => l10n.cars,
    'ACCOMMODATION' => l10n.accommodations,
    'HONEYMOON' => l10n.honeymoon,
    'FLIGHT' => l10n.flights,
    'HOTEL' => l10n.hotels,
    _ => l10n.bookings,
  };
}

IconData bookingTypeIcon(String? type) {
  return switch (type) {
    'FLIGHT' => Icons.flight_takeoff_outlined,
    'HOTEL' => Icons.domain_outlined,
    _ => favoriteTypeIcon(type),
  };
}

dynamic bookingTitleRaw(Map<String, dynamic> raw) {
  if (raw['venue'] is Map) {
    return (raw['venue'] as Map)['name'];
  }
  if (raw['listing'] is Map) {
    return (raw['listing'] as Map)['title'];
  }
  if (raw['car'] is Map) {
    return (raw['car'] as Map)['name'];
  }
  if (raw['accommodation'] is Map) {
    return (raw['accommodation'] as Map)['name'];
  }
  if (raw['honeymoon'] is Map) {
    return (raw['honeymoon'] as Map)['name'];
  }
  return raw['bookingNumber'] ?? raw['type'];
}

Map<String, dynamic>? bookingResource(Map<String, dynamic> raw) {
  for (final key in ['venue', 'listing', 'car', 'accommodation', 'honeymoon']) {
    final value = raw[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return null;
}

String prettyEnumLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String? bookingVendorUserId(Map<String, dynamic> raw) {
  final vendor = raw['vendor'] is Map ? Map<String, dynamic>.from(raw['vendor'] as Map) : const <String, dynamic>{};
  final nested = vendor['user'] is Map ? Map<String, dynamic>.from(vendor['user'] as Map) : const <String, dynamic>{};
  final id = vendor['userId']?.toString() ?? nested['id']?.toString() ?? '';
  return id.isEmpty ? null : id;
}

String bookingGuestName(Map<String, dynamic> raw) {
  final customer = raw['customer'] is Map ? Map<String, dynamic>.from(raw['customer'] as Map) : const <String, dynamic>{};
  final name = [customer['firstName'], customer['lastName']]
      .map((value) => value?.toString().trim() ?? '')
      .where((value) => value.isNotEmpty)
      .join(' ');
  return name;
}

String? bookingCustomerId(Map<String, dynamic> raw) {
  final customer = raw['customer'] is Map ? Map<String, dynamic>.from(raw['customer'] as Map) : const <String, dynamic>{};
  final id = raw['customerId']?.toString() ?? customer['id']?.toString() ?? '';
  return id.isEmpty ? null : id;
}

String? bookingChatPeerId(Map<String, dynamic> raw, String myId) {
  final vendorUserId = bookingVendorUserId(raw);
  final customerId = bookingCustomerId(raw);
  if (myId.isNotEmpty && myId == vendorUserId) {
    return customerId;
  }
  if (myId.isNotEmpty && myId == customerId) {
    return vendorUserId;
  }
  return vendorUserId ?? customerId;
}

bool bookingHasAmount(Map<String, dynamic> raw) {
  final total = num.tryParse('${raw['totalAmount'] ?? 0}') ?? 0;
  final paid = bookingPaidTotal(raw);
  final remaining = num.tryParse('${raw['balanceAmount'] ?? 0}') ?? 0;
  return total > 0 || paid > 0 || remaining > 0;
}

String formatMoney(dynamic amount, [String currency = 'AED']) {
  final number = num.tryParse('$amount') ?? 0;
  final formatted = number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]},',
      );
  return '$currency $formatted';
}

List<Map<String, dynamic>> bookingPayments(Map<String, dynamic> raw) {
  final list = raw['payments'];
  if (list is! List) {
    return const [];
  }
  return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

bool bookingKindPaid(Map<String, dynamic> raw, String kind) {
  return bookingPayments(raw).any((row) => row['kind'] == kind && row['status'] == 'SUCCEEDED');
}

const vendorInboxStatuses = {'INQUIRY', 'PENDING', 'UNDER_REVIEW', 'DRAFT'};

bool bookingNeedsVendorDecision(String? status) {
  return vendorInboxStatuses.contains((status ?? '').toUpperCase());
}

Map<String, dynamic>? bookingReviewState(Map<String, dynamic> raw) {
  final state = raw['reviewState'];
  if (state is Map) {
    return Map<String, dynamic>.from(state);
  }
  return null;
}

bool bookingCanReview(Map<String, dynamic> raw) {
  return bookingReviewState(raw)?['canWrite'] == true;
}

Map<String, dynamic>? bookingReviewMine(Map<String, dynamic> raw) {
  final mine = bookingReviewState(raw)?['mine'];
  if (mine is Map) {
    return Map<String, dynamic>.from(mine);
  }
  return null;
}

Map<String, dynamic>? bookingReviewTheirs(Map<String, dynamic> raw) {
  final theirs = bookingReviewState(raw)?['theirs'];
  if (theirs is Map) {
    return Map<String, dynamic>.from(theirs);
  }
  return null;
}

List<Map<String, dynamic>> catalogPublicReviews(Map<String, dynamic> raw) {
  final list = raw['reviews'];
  if (list is! List) {
    return const [];
  }
  return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

bool bookingCanPay(Map<String, dynamic> raw, String kind) {
  final status = raw['status']?.toString() ?? '';
  if (const {'CANCELLED', 'REJECTED', 'REFUNDED'}.contains(status)) {
    return false;
  }
  final amount = num.tryParse('${raw[kind == 'DEPOSIT' ? 'depositAmount' : 'balanceAmount'] ?? 0}') ?? 0;
  if (amount <= 0 || bookingKindPaid(raw, kind)) {
    return false;
  }
  if (kind == 'BALANCE' && !bookingKindPaid(raw, 'DEPOSIT') && (num.tryParse('${raw['depositAmount'] ?? 0}') ?? 0) > 0) {
    return false;
  }
  return true;
}

num bookingPaidTotal(Map<String, dynamic> raw) {
  return bookingPayments(raw)
      .where((row) => row['status'] == 'SUCCEEDED')
      .fold<num>(0, (acc, row) => acc + (num.tryParse('${row['amount'] ?? 0}') ?? 0));
}

IconData notificationTypeIcon(Map<String, dynamic> raw) {
  final payload = notificationPayload(raw);
  if ((payload['bookingId']?.toString() ?? '').isNotEmpty) {
    return Icons.receipt_long_outlined;
  }
  if ((payload['visitId']?.toString() ?? '').isNotEmpty) {
    return Icons.meeting_room_outlined;
  }
  if ((payload['conversationId']?.toString() ?? '').isNotEmpty) {
    return Icons.chat_bubble_outline_rounded;
  }
  final type = (payload['type'] ?? raw['channel'])?.toString().toUpperCase() ?? '';
  if (type.contains('PAY')) {
    return Icons.payments_outlined;
  }
  if (type.contains('EVENT')) {
    return Icons.celebration_outlined;
  }
  return Icons.notifications_none_rounded;
}
