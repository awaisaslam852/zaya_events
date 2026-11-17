import '../../../core/constants/countries.dart';
import '../../../l10n/app_localizations.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class RegisterFormErrors {
  const RegisterFormErrors({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phone,
    this.country,
    this.businessName,
    this.city,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? phone;
  final String? country;
  final String? businessName;
  final String? city;

  bool get hasErrors => messages.isNotEmpty;

  List<String> get messages => [
        if (firstName != null) firstName!,
        if (lastName != null) lastName!,
        if (email != null) email!,
        if (password != null) password!,
        if (phone != null) phone!,
        if (country != null) country!,
        if (businessName != null) businessName!,
        if (city != null) city!,
      ];

  String popupMessage(AppLocalizations l10n) {
    final items = messages.toSet().toList();
    if (items.isEmpty) {
      return l10n.fixHighlightedFields;
    }
    if (items.length == 1) {
      return items.first;
    }
    return '${l10n.fixHighlightedFields}\n\n${items.map((item) => '• $item').join('\n')}';
  }

  RegisterFormErrors clear(String field) {
    return RegisterFormErrors(
      firstName: field == 'firstName' ? null : firstName,
      lastName: field == 'lastName' ? null : lastName,
      email: field == 'email' ? null : email,
      password: field == 'password' ? null : password,
      phone: field == 'phone' ? null : phone,
      country: field == 'country' ? null : country,
      businessName: field == 'businessName' ? null : businessName,
      city: field == 'city' ? null : city,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RegisterFormErrors &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        email == other.email &&
        password == other.password &&
        phone == other.phone &&
        country == other.country &&
        businessName == other.businessName &&
        city == other.city;
  }

  @override
  int get hashCode => Object.hash(firstName, lastName, email, password, phone, country, businessName, city);
}

class LoginFormErrors {
  const LoginFormErrors({this.email, this.password});

  final String? email;
  final String? password;

  bool get hasErrors => email != null || password != null;

  List<String> get messages => [
        if (email != null) email!,
        if (password != null) password!,
      ];

  String popupMessage(AppLocalizations l10n) {
    final items = messages;
    if (items.isEmpty) {
      return l10n.fixHighlightedFields;
    }
    if (items.length == 1) {
      return items.first;
    }
    return '${l10n.fixHighlightedFields}\n\n${items.map((item) => '• $item').join('\n')}';
  }
}

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

RegisterFormErrors validateRegisterForm({
  required AppLocalizations l10n,
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String phone,
  required String country,
  required String role,
  required String businessName,
  required String city,
}) {
  final vendor = role == 'vendor';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return RegisterFormErrors(
    firstName: firstName.trim().isEmpty ? l10n.enterFirstName : null,
    lastName: lastName.trim().isEmpty ? l10n.enterLastName : null,
    email: email.trim().isEmpty
        ? l10n.enterEmail
        : (isValidEmail(email) ? null : l10n.invalidEmail),
    password: password.length < 8 ? l10n.passwordMinLength : (password.length > 72 ? l10n.passwordMinLength : null),
    phone: vendor && digits.length < 8 ? l10n.enterVendorPhone : null,
    country: countryByCode(country) == null ? l10n.chooseCountryError : null,
    businessName: vendor && businessName.trim().isEmpty ? l10n.enterBusinessName : null,
    city: vendor && city.trim().isEmpty ? l10n.enterCity : null,
  );
}

LoginFormErrors validateLoginForm({
  required AppLocalizations l10n,
  required String email,
  required String password,
}) {
  return LoginFormErrors(
    email: email.trim().isEmpty ? l10n.enterEmail : (isValidEmail(email) ? null : l10n.invalidEmail),
    password: password.isEmpty ? l10n.enterLoginPassword : null,
  );
}

String localizeApiFieldError(AppLocalizations l10n, String key, String raw) {
  final lower = raw.toLowerCase();
  switch (key) {
    case 'firstName':
      return l10n.enterFirstName;
    case 'lastName':
      return l10n.enterLastName;
    case 'email':
      if (lower.contains('exist') || lower.contains('taken') || lower.contains('already')) {
        return l10n.emailAlreadyUsed;
      }
      return l10n.invalidEmail;
    case 'password':
      return l10n.passwordMinLength;
    case 'phone':
      return l10n.enterVendorPhone;
    case 'country':
      return l10n.chooseCountryError;
    case 'city':
      return l10n.enterCity;
    case 'businessName':
    case 'businessName.en':
    case 'businessName.ar':
      return l10n.enterBusinessName;
    default:
      return raw;
  }
}

RegisterFormErrors registerErrorsFromApi({
  required AppLocalizations l10n,
  String? message,
  Map<String, String>? fieldErrors,
  String? code,
}) {
  final mapped = <String, String>{};
  fieldErrors?.forEach((key, value) {
    mapped[key] = localizeApiFieldError(l10n, key, value);
  });

  final lower = (message ?? '').toLowerCase();
  if ((code == 'CONFLICT' || lower.contains('already exists') || lower.contains('already registered')) &&
      mapped['email'] == null) {
    mapped['email'] = l10n.emailAlreadyUsed;
  }

  if (mapped.isEmpty) {
    if (lower.contains('password') || lower.contains('8 character')) {
      mapped['password'] = l10n.passwordMinLength;
    } else if (lower.contains('email') && (lower.contains('invalid') || lower.contains('valid'))) {
      mapped['email'] = l10n.invalidEmail;
    }
  }

  return RegisterFormErrors(
    firstName: mapped['firstName'],
    lastName: mapped['lastName'],
    email: mapped['email'],
    password: mapped['password'],
    phone: mapped['phone'],
    country: mapped['country'],
    businessName: mapped['businessName'] ?? mapped['businessName.en'] ?? mapped['businessName.ar'],
    city: mapped['city'],
  );
}

String humanizeAuthMessage({
  required AppLocalizations l10n,
  String? message,
  Map<String, String>? fieldErrors,
  String? code,
}) {
  final errors = registerErrorsFromApi(
    l10n: l10n,
    message: message,
    fieldErrors: fieldErrors,
    code: code,
  );
  if (errors.hasErrors) {
    return errors.popupMessage(l10n);
  }
  if (message == null || message.isEmpty || message == 'Validation failed' || message == 'errorGeneric') {
    return l10n.errorGeneric;
  }
  return message;
}
