import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/constants/countries.dart';
import 'package:zaya_events/core/network/api_envelope.dart';
import 'package:zaya_events/core/widgets/country_picker.dart';
import 'package:zaya_events/core/widgets/zaya_dialogs.dart';
import 'package:zaya_events/features/auth/presentation/pages/register_page.dart';
import 'package:zaya_events/features/auth/presentation/register_form_errors.dart';
import 'package:zaya_events/l10n/app_localizations_en.dart';

import 'support/test_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('6-character password fails before the API is called', () {
    final errors = validateRegisterForm(
      l10n: l10n,
      firstName: 'Aroosh',
      lastName: 'Awais',
      email: 'arooshawais@gmail.com',
      password: '112233',
      phone: '03034240832',
      country: 'PK',
      role: 'customer',
      businessName: '',
      city: '',
    );

    expect(errors.password, l10n.passwordMinLength);
    expect(errors.firstName, isNull);
    expect(errors.email, isNull);
    expect(errors.popupMessage(l10n), l10n.passwordMinLength);
  });

  test('API password flatten maps onto the password field', () {
    final errors = registerErrorsFromApi(
      l10n: l10n,
      message: 'Validation failed',
      fieldErrors: const {'password': 'String must contain at least 8 character(s)'},
    );

    expect(errors.password, l10n.passwordMinLength);
    expect(
      humanizeAuthMessage(
        l10n: l10n,
        message: 'Validation failed',
        fieldErrors: const {'password': 'String must contain at least 8 character(s)'},
      ),
      l10n.passwordMinLength,
    );
  });

  test('duplicate email is shown on the email field', () {
    final errors = registerErrorsFromApi(
      l10n: l10n,
      message: 'An account with this email already exists',
      code: 'CONFLICT',
    );
    expect(errors.email, l10n.emailAlreadyUsed);
  });

  test('country search matches name, code and Arabic', () {
    expect(filterCountries('pak').map((c) => c.code), ['PK']);
    expect(filterCountries('PK').map((c) => c.code), ['PK']);
    expect(filterCountries('باكستان').map((c) => c.code), ['PK']);
    expect(filterCountries('united').map((c) => c.code), containsAll(['AE', 'GB', 'US']));
  });

  test('zod flatten details become field errors', () {
    final fields = parseZodFieldErrors({
      'formErrors': <String>[],
      'fieldErrors': {
        'password': ['String must contain at least 8 character(s)'],
        'email': ['Invalid email'],
      },
    });
    expect(fields, {
      'password': 'String must contain at least 8 character(s)',
      'email': 'Invalid email',
    });
  });

  testWidgets('register form shows popup and field error for a short password', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    RegisterDraft? submitted;
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: RegisterForm(
            busy: false,
            onSubmit: (draft) => submitted = draft,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Aroosh');
    await tester.enterText(find.byType(TextField).at(1), 'Awais');
    await tester.enterText(find.byType(TextField).at(2), 'arooshawais@gmail.com');
    await tester.enterText(find.byType(TextField).at(3), '112233');
    final submit = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(submitted, isNull);
    expect(find.textContaining('Venues, vendors'), findsNothing);
    expect(find.text('Check your details'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters.'), findsWidgets);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('country picker can search and select Pakistan', (tester) async {
    var selected = 'AE';
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return CountryPickerField(
                selectedCode: selected,
                onChanged: (value) => setState(() => selected = value),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.textContaining('United Arab Emirates'));
    await tester.pumpAndSettle();
    expect(find.text('Choose country'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pak');
    await tester.pumpAndSettle();
    expect(find.text('Pakistan'), findsOneWidget);

    await tester.tap(find.text('Pakistan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pakistan'), findsOneWidget);
    expect(find.textContaining('United Arab Emirates'), findsNothing);
  });

  testWidgets('alert dialog uses a single Got it action', (tester) async {
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => showZayaAlert(
                context,
                title: 'Check your details',
                message: 'Password must be at least 8 characters.',
              ),
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Check your details'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
  });
}
