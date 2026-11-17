import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/widgets/zaya_dialogs.dart';
import 'package:zaya_events/l10n/app_localizations_en.dart';

import 'support/test_app.dart';

void main() {
  test('delete catalog copy names the listing', () {
    final l10n = AppLocalizationsEn();
    expect(l10n.deleteCatalogTitle, 'Delete this listing?');
    expect(l10n.deleteCatalogMessage('Taj mahal'), contains('Taj mahal'));
    expect(l10n.deleteCatalogMessage('Taj mahal'), isNot(l10n.catalogSubtitle));
    expect(l10n.logoutTitle, contains('Log out'));
  });

  testWidgets('confirm dialog shows title, message and actions', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(
      testApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                confirmed = await showZayaConfirm(
                  context,
                  title: 'Delete this listing?',
                  message: '“Taj mahal” will be removed from your catalog. This cannot be undone.',
                  confirmLabel: 'Delete',
                  icon: Icons.delete_outline,
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this listing?'), findsOneWidget);
    expect(find.textContaining('Taj mahal'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });
}
