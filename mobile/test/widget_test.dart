import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/auth/app_role.dart';
import 'package:zaya_events/core/utils/localized.dart';

void main() {
  test('parseAppRole maps backend roles', () {
    expect(parseAppRole('CUSTOMER'), AppRole.customer);
    expect(parseAppRole('vendor'), AppRole.vendor);
    expect(parseAppRole('ADMIN'), AppRole.admin);
  });

  test('localized prefers locale then English', () {
    expect(localized({'en': 'Hello', 'ar': 'مرحبا'}, 'ar'), 'مرحبا');
    expect(localized({'en': 'Hello'}, 'ar'), 'Hello');
  });
}
