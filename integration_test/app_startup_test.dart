import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serba_jaya_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots and opens the guest login gate on device', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keranjang'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Silakan masuk'), findsOneWidget);
  });
}
