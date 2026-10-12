enum AppRole { customer, vendor, admin }

AppRole parseAppRole(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'VENDOR':
      return AppRole.vendor;
    case 'ADMIN':
      return AppRole.admin;
    default:
      return AppRole.customer;
  }
}

String roleToApi(AppRole role) {
  switch (role) {
    case AppRole.customer:
      return 'customer';
    case AppRole.vendor:
      return 'vendor';
    case AppRole.admin:
      return 'admin';
  }
}
