class VendorDashboardMetrics {
  const VendorDashboardMetrics(this.earnings, this.me, this.reviews);

  final Map<String, dynamic>? earnings;
  final Map<String, dynamic>? me;
  final Map<String, dynamic>? reviews;

  List<Map<String, dynamic>> get bookings {
    final raw = earnings?['bookings'];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  int get bookingCount => bookings.length;

  num get totalAmount {
    final totals = earnings?['totals'];
    if (totals is Map) {
      return num.tryParse(totals['total']?.toString() ?? '') ?? 0;
    }
    return num.tryParse(totals?.toString() ?? '') ?? 0;
  }

  String get currency {
    for (final booking in bookings) {
      final value = booking['currency']?.toString();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  int get confirmedCount {
    return bookings.where((row) {
      final status = (row['status']?.toString() ?? '').toUpperCase();
      return status == 'CONFIRMED' ||
          status == 'PAID' ||
          status == 'COMPLETED' ||
          status == 'IN_PROGRESS';
    }).length;
  }

  int get pendingCount {
    return bookings.where((row) {
      final status = (row['status']?.toString() ?? '').toUpperCase();
      return status == 'INQUIRY' ||
          status == 'PENDING' ||
          status == 'UNDER_REVIEW' ||
          status == 'DRAFT';
    }).length;
  }

  String get occupancy {
    if (bookings.isEmpty) {
      return '—';
    }
    return '${((confirmedCount / bookings.length) * 100).round()}%';
  }

  String get rating {
    final avg = reviews?['ratingAvg'] ?? me?['ratingAvg'];
    final count = reviews?['ratingCount'] ?? me?['ratingCount'] ?? 0;
    if (avg == null) {
      return '—';
    }
    final number = num.tryParse(avg.toString());
    final pretty = number == null
        ? avg.toString()
        : number.toStringAsFixed(number % 1 == 0 ? 1 : 1);
    return '$pretty · $count';
  }

  bool get isApproved =>
      (me?['status']?.toString() ?? '').toUpperCase() == 'APPROVED';
}
