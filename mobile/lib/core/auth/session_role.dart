import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'app_role.dart';

AuthBloc? _authBloc(BuildContext context) {
  try {
    return BlocProvider.of<AuthBloc>(context, listen: false);
  } catch (_) {
    return null;
  }
}

AppRole sessionAppRole(BuildContext context) {
  final state = _authBloc(context)?.state;
  if (state == null) {
    return AppRole.customer;
  }
  return state.maybeWhen(
    authenticated: (user) => parseAppRole(user.role),
    orElse: () => AppRole.customer,
  );
}

bool isVendorSession(BuildContext context) => sessionAppRole(context) == AppRole.vendor;

String? sessionUserId(BuildContext context) {
  final state = _authBloc(context)?.state;
  if (state == null) {
    return null;
  }
  return state.maybeWhen(authenticated: (user) => user.id, orElse: () => null);
}

String? sessionVendorId(BuildContext context) {
  final state = _authBloc(context)?.state;
  if (state == null) {
    return null;
  }
  return state.maybeWhen(
    authenticated: (user) {
      final id = user.vendor?['id']?.toString();
      return (id == null || id.isEmpty) ? null : id;
    },
    orElse: () => null,
  );
}

bool catalogOwnedByViewer(
  Map<String, dynamic> raw, {
  String? userId,
  String? vendorId,
}) {
  if (vendorId != null && vendorId.isNotEmpty) {
    final owner = raw['vendorId']?.toString() ??
        (raw['vendor'] is Map ? (raw['vendor'] as Map)['id']?.toString() : null);
    if (owner != null && owner.isNotEmpty && owner == vendorId) {
      return true;
    }
  }
  if (userId != null && userId.isNotEmpty) {
    if (raw['userId']?.toString() == userId) {
      return true;
    }
    final vendor = raw['vendor'];
    if (vendor is Map) {
      final nestedUser = vendor['userId']?.toString() ??
          (vendor['user'] is Map ? (vendor['user'] as Map)['id']?.toString() : null);
      if (nestedUser == userId) {
        return true;
      }
    }
  }
  return false;
}
