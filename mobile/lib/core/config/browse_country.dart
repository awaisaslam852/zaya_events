import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

String? currentUserCountry() {
  if (!GetIt.I.isRegistered<AuthBloc>()) {
    return null;
  }
  return GetIt.I<AuthBloc>().state.maybeWhen(
    authenticated: (user) => user.country,
    orElse: () => null,
  );
}

Map<String, dynamic> browseQuery([Map<String, dynamic>? extra]) {
  final country = currentUserCountry();
  return {
    if (country != null && country.isNotEmpty) 'country': country,
    ...?extra,
  };
}
