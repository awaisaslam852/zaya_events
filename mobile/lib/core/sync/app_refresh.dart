import 'dart:async';

enum AppRefreshTopic {
  bookings,
  visits,
  events,
  cart,
  favorites,
  notifications,
  vendorCatalog,
  vendorDashboard,
  chat,
  payments,
}

/// Broadcasts data changes so mounted screens can reload without sharing cubits.
class AppRefresh {
  AppRefresh._();
  static final AppRefresh instance = AppRefresh._();

  final StreamController<AppRefreshTopic> _controller = StreamController<AppRefreshTopic>.broadcast();

  Stream<AppRefreshTopic> get stream => _controller.stream;

  void ping(AppRefreshTopic topic) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(topic);
  }

  void pingMany(Iterable<AppRefreshTopic> topics) {
    for (final topic in topics) {
      ping(topic);
    }
  }

  void afterBooking() {
    pingMany(const [
      AppRefreshTopic.bookings,
      AppRefreshTopic.vendorDashboard,
      AppRefreshTopic.payments,
      AppRefreshTopic.notifications,
      AppRefreshTopic.events,
    ]);
  }

  void afterVisit() {
    pingMany(const [
      AppRefreshTopic.visits,
      AppRefreshTopic.vendorDashboard,
      AppRefreshTopic.notifications,
      AppRefreshTopic.events,
    ]);
  }

  void afterCart() => ping(AppRefreshTopic.cart);

  void afterCheckout() {
    afterCart();
    afterBooking();
  }

  void afterFavorite() => ping(AppRefreshTopic.favorites);

  void afterEvent() => ping(AppRefreshTopic.events);

  void afterVendorCatalog() {
    pingMany(const [AppRefreshTopic.vendorCatalog, AppRefreshTopic.vendorDashboard]);
  }

  void afterChat() => ping(AppRefreshTopic.chat);
}
