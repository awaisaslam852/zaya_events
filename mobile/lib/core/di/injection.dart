import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../config/app_settings.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../notifications/push_bootstrap.dart';
import '../realtime/socket_service.dart';
import '../storage/token_storage.dart';
import '../../features/accommodations/data/repositories/accommodations_repository_impl.dart';
import '../../features/accommodations/domain/repositories/accommodations_repository.dart';
import '../../features/accommodations/domain/usecases/accommodations_usecases.dart';
import '../../features/accommodations/presentation/cubit/accommodations_cubit.dart';
import '../../features/ai_planner/domain/ai_usecases.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/availability_calendar/domain/availability_usecases.dart';
import '../../features/booking_requests/domain/booking_requests_usecases.dart';
import '../../features/bookings/data/repositories/bookings_repository_impl.dart';
import '../../features/bookings/domain/repositories/bookings_repository.dart';
import '../../features/bookings/domain/usecases/bookings_usecases.dart';
import '../../features/bookings/presentation/cubit/bookings_cubit.dart';
import '../../features/calls/data/repositories/call_repository_impl.dart';
import '../../features/calls/domain/repositories/call_repository.dart';
import '../../features/calls/domain/usecases/call_usecases.dart';
import '../../features/calls/presentation/bloc/call_bloc.dart';
import '../../features/cars/data/repositories/cars_repository_impl.dart';
import '../../features/cars/domain/repositories/cars_repository.dart';
import '../../features/cars/domain/usecases/cars_usecases.dart';
import '../../features/cars/presentation/cubit/cars_cubit.dart';
import '../../features/chat/domain/chat_usecases.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/events_usecases.dart';
import '../../features/events/presentation/cubit/events_cubit.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/favorites_usecases.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/flights/data/repositories/flights_repository_impl.dart';
import '../../features/flights/domain/repositories/flights_repository.dart';
import '../../features/flights/domain/usecases/flights_usecases.dart';
import '../../features/flights/presentation/cubit/flights_cubit.dart';
import '../../features/home/data/banners_repository.dart';
import '../../features/home/presentation/cubit/banners_cubit.dart';
import '../../features/honeymoon/data/repositories/honeymoon_repository_impl.dart';
import '../../features/honeymoon/domain/repositories/honeymoon_repository.dart';
import '../../features/honeymoon/domain/usecases/honeymoon_usecases.dart';
import '../../features/honeymoon/presentation/cubit/honeymoon_cubit.dart';
import '../../features/hotels/data/repositories/hotels_repository_impl.dart';
import '../../features/hotels/domain/repositories/hotels_repository.dart';
import '../../features/hotels/domain/usecases/hotels_usecases.dart';
import '../../features/hotels/presentation/cubit/hotels_cubit.dart';
import '../../features/listings/domain/listings_usecases.dart';
import '../../features/listings/presentation/cubit/listings_cubit.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/notifications_usecases.dart';
import '../../features/notifications/domain/usecases/register_device.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/settings/presentation/cubit/locale_cubit.dart';
import '../../features/uploads/data/repositories/upload_repository_impl.dart';
import '../../features/uploads/domain/repositories/upload_repository.dart';
import '../../features/uploads/domain/usecases/upload_file.dart';
import '../../features/uploads/presentation/upload_service.dart';
import '../../features/vendor_dashboard/domain/vendor_dashboard_usecases.dart';
import '../../features/vendor_dashboard/presentation/cubit/vendor_dashboard_cubit.dart';
import '../../features/vendors_browse/data/repositories/vendors_repository_impl.dart';
import '../../features/vendors_browse/domain/repositories/vendors_repository.dart';
import '../../features/vendors_browse/domain/usecases/vendors_usecases.dart';
import '../../features/vendors_browse/presentation/cubit/vendors_cubit.dart';
import '../../features/venue_visits/data/repositories/visits_repository_impl.dart';
import '../../features/venue_visits/domain/repositories/visits_repository.dart';
import '../../features/venue_visits/domain/usecases/visits_usecases.dart';
import '../../features/venue_visits/presentation/cubit/visits_cubit.dart';
import '../../features/venues/data/repositories/venues_repository_impl.dart';
import '../../features/venues/domain/repositories/venues_repository.dart';
import '../../features/venues/domain/usecases/venues_usecases.dart';
import '../../features/venues/presentation/cubit/venues_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<AuthBloc>()) {
    return;
  }
  final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 5));
  sl.registerSingleton(prefs);
  sl.registerSingleton(await AppConfig.resolve(prefsOverride: prefs.getString(AppConfig.prefsOverrideKey)));
  sl.registerSingleton(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
      ),
    ),
  );
  sl.registerSingleton(TokenStorage(sl()));
  sl.registerSingleton(SocketService(sl(), sl()));

  final refreshDio = Dio();
  sl.registerSingleton(
    AuthInterceptor(storage: sl(), config: sl(), refreshDio: refreshDio),
  );
  sl.registerSingleton(ApiClient(config: sl(), interceptor: sl()));
  sl.registerSingleton(AppSettings());
  unawaited(sl<AppSettings>().refresh(sl()));
  sl<AuthInterceptor>().onForceLogout = () {
    if (sl.isRegistered<AuthBloc>()) {
      sl<AuthBloc>().add(const AuthEvent.logout());
    }
  };

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => RestoreSessionUseCase(sl()));
  sl.registerFactory(() => LogoutUseCase(sl()));
  sl.registerFactory(() => GetMeUseCase(sl()));
  sl.registerFactory(() => ForgotPasswordUseCase(sl()));
  sl.registerFactory(() => ResetPasswordUseCase(sl()));
  sl.registerFactory(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(login: sl(), register: sl(), restore: sl(), logout: sl(), sockets: sl()),
  );

  sl.registerLazySingleton<UploadRepository>(() => UploadRepositoryImpl(sl()));
  sl.registerFactory(() => UploadFile(sl()));
  sl.registerLazySingleton(() => UploadService(sl()));

  sl.registerFactory(() => RegisterDevice(sl()));
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  sl.registerLazySingleton<CallRepository>(() => CallRepositoryImpl(sl()));
  sl.registerFactory(() => InitiateCall(sl()));
  sl.registerFactory(() => AcceptCall(sl()));
  sl.registerFactory(() => RejectCall(sl()));
  sl.registerFactory(() => EndCall(sl()));
  sl.registerFactory(() => GetCallToken(sl()));
  sl.registerFactory(() => ListCallHistory(sl()));
  sl.registerLazySingleton(
    () => CallBloc(
      initiate: sl(),
      accept: sl(),
      reject: sl(),
      end: sl(),
      token: sl(),
      history: sl(),
      sockets: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => PushBootstrap(messaging: sl(), local: sl(), callBloc: sl(), registerDevice: sl()),
  );

  sl.registerLazySingleton(() => ChatRepository(sl()));
  sl.registerFactory(() => ListConversations(sl()));
  sl.registerFactory(() => ListMessages(sl()));
  sl.registerFactory(() => SendMessage(sl()));
  sl.registerFactory(() => GetConversation(sl()));
  sl.registerFactory(() => StartConversation(sl()));
  sl.registerFactory(() => StartSupport(sl()));
  sl.registerFactory(() => ChatCubit(sl(), sl(), sl(), sl(), sl()));

  sl.registerLazySingleton(() => LocaleCubit(sl()));

  sl.registerLazySingleton(() => BannersRepository(sl()));
  sl.registerFactory(() => BannersCubit(sl()));

  sl.registerLazySingleton<VenuesRepository>(() => VenuesRepositoryImpl(sl()));
  sl.registerFactory(() => ListVenues(sl()));
  sl.registerFactory(() => GetVenues(sl()));
  sl.registerFactory(() => VenuesCubit(sl(), sl()));

  sl.registerLazySingleton<VendorsRepository>(() => VendorsRepositoryImpl(sl()));
  sl.registerFactory(() => ListVendors(sl()));
  sl.registerFactory(() => GetVendors(sl()));
  sl.registerFactory(() => VendorsCubit(sl(), sl()));

  sl.registerLazySingleton<CarsRepository>(() => CarsRepositoryImpl(sl()));
  sl.registerFactory(() => ListCars(sl()));
  sl.registerFactory(() => GetCars(sl()));
  sl.registerFactory(() => CarsCubit(sl(), sl()));

  sl.registerLazySingleton<AccommodationsRepository>(() => AccommodationsRepositoryImpl(sl()));
  sl.registerFactory(() => ListAccommodations(sl()));
  sl.registerFactory(() => GetAccommodations(sl()));
  sl.registerFactory(() => AccommodationsCubit(sl(), sl()));

  sl.registerLazySingleton<HoneymoonRepository>(() => HoneymoonRepositoryImpl(sl()));
  sl.registerFactory(() => ListHoneymoon(sl()));
  sl.registerFactory(() => GetHoneymoon(sl()));
  sl.registerFactory(() => HoneymoonCubit(sl(), sl()));

  sl.registerLazySingleton<FlightsRepository>(() => FlightsRepositoryImpl(sl()));
  sl.registerFactory(() => ListFlights(sl()));
  sl.registerFactory(() => GetFlights(sl()));
  sl.registerFactory(() => InquireFlights(sl()));
  sl.registerFactory(() => FlightsCubit(sl(), sl(), sl()));

  sl.registerLazySingleton<HotelsRepository>(() => HotelsRepositoryImpl(sl()));
  sl.registerFactory(() => ListHotels(sl()));
  sl.registerFactory(() => GetHotels(sl()));
  sl.registerFactory(() => InquireHotels(sl()));
  sl.registerFactory(() => HotelsCubit(sl(), sl(), sl()));

  sl.registerLazySingleton<EventsRepository>(() => EventsRepositoryImpl(sl()));
  sl.registerFactory(() => ListEvents(sl()));
  sl.registerFactory(() => GetEvents(sl()));
  sl.registerFactory(() => CreateEvent(sl()));
  sl.registerFactory(() => UpdateEvent(sl()));
  sl.registerFactory(() => EventsCubit(sl(), sl(), sl(), sl()));

  sl.registerLazySingleton<BookingsRepository>(() => BookingsRepositoryImpl(sl()));
  sl.registerFactory(() => ListBookings(sl()));
  sl.registerFactory(() => GetBookings(sl()));
  sl.registerFactory(() => ModifyBooking(sl()));
  sl.registerFactory(() => CancelBooking(sl()));
  sl.registerFactory(() => CreateBookingPayment(sl()));
  sl.registerFactory(() => ConfirmBookingPayment(sl()));
  sl.registerFactory(() => BookingsCubit(sl(), sl(), sl(), sl(), sl(), sl()));

  sl.registerLazySingleton<VisitsRepository>(() => VisitsRepositoryImpl(sl()));
  sl.registerFactory(() => ListVisits(sl()));
  sl.registerFactory(() => GetVisits(sl()));
  sl.registerFactory(() => CancelVisit(sl()));
  sl.registerFactory(() => DecideVisit(sl()));
  sl.registerFactory(() => VisitsCubit(sl(), sl(), sl(), sl()));

  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(sl()));
  sl.registerFactory(() => ListFavorites(sl()));
  sl.registerFactory(() => GetFavorites(sl()));
  sl.registerFactory(() => FavoritesCubit(sl(), sl()));

  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl()));
  sl.registerFactory(() => ListNotifications(sl()));
  sl.registerFactory(() => GetNotifications(sl()));
  sl.registerFactory(() => NotificationsCubit(sl(), sl()));

  sl.registerLazySingleton(() => VendorDashboardRepository(sl()));
  sl.registerFactory(() => GetVendorMe(sl()));
  sl.registerFactory(() => GetVendorEarnings(sl()));
  sl.registerFactory(() => GetVendorReviews(sl()));
  sl.registerFactory(() => UpdateVendorProfile(sl()));
  sl.registerFactory(() => VendorDashboardCubit(sl(), sl(), sl()));

  sl.registerLazySingleton(() => ListingsRepository(sl()));
  sl.registerFactory(() => ListVendorListings(sl()));
  sl.registerFactory(() => GetListing(sl()));
  sl.registerFactory(() => CreateListing(sl()));
  sl.registerFactory(() => UpdateListing(sl()));
  sl.registerFactory(() => DeleteListing(sl()));
  sl.registerFactory(() => AddListingPackage(sl()));
  sl.registerFactory(() => ListingsCubit(sl(), sl(), sl(), sl(), sl()));

  sl.registerLazySingleton(() => AvailabilityRepository(sl()));
  sl.registerFactory(() => ListAvailability(sl()));
  sl.registerFactory(() => UpsertAvailability(sl()));

  sl.registerLazySingleton(() => BookingRequestsRepository(sl()));
  sl.registerFactory(() => ListBookingRequests(sl()));
  sl.registerFactory(() => TransitionBooking(sl()));

  sl.registerLazySingleton(() => AiPlannerRepository(sl()));
  sl.registerFactory(() => AiChat(sl()));
}
