import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/login_required_dialog.dart';
import 'package:serba_jaya_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots and opens the guest login gate on device', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Secure storage restoration completes outside the widget test clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu Harus Masuk'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byType(LoginRequiredDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Kamu Harus Masuk'), findsNothing);
    expect(find.byType(AppBottomNavBar), findsOneWidget);

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu Harus Masuk'), findsNothing);

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing);
  });
}
