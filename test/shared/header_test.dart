import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_header.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_search_field.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_mobile.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_page_title.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_search.dart';

void main() {
  testWidgets('mobile Header variants expose their real design assets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppHeader(child: HeaderMobile()),
              AppHeader(child: HeaderMobileActions()),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(HeaderMobile), findsOneWidget);
    expect(find.byType(HeaderMobileActions), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.headerLogo,
      ),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('page title Header supports dynamic title and cart callback', (
    tester,
  ) async {
    var cartTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppHeader(
            child: HeaderPageTitle(
              title: 'Detail Produk',
              onCartTap: () => cartTaps++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Produk'), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(HeaderPageTitle),
            matching: find.byType(HeaderActionButton),
          )
          .last,
    );
    expect(cartTaps, 1);
    expect(tester.getSize(find.byType(HeaderPageTitle)).height, 55);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search Header clears its query and reports changes', (
    tester,
  ) async {
    final changes = <String>[];
    var clearTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppHeader(
            child: HeaderSearch(
              query: 'Jeruk',
              onChanged: changes.add,
              onClear: () => clearTaps++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Jeruk'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-search-clear')));
    await tester.pumpAndSettle();
    expect(changes, ['']);
    expect(clearTaps, 1);
    expect(find.text('Jeruk'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search field accepts typing and shows clear action', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: AppSearchField(onChanged: (text) => value = text),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Beras');
    await tester.pumpAndSettle();

    expect(value, 'Beras');
    expect(find.byKey(const Key('app-search-clear')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'header badges replace the screenshot sample and fit small width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var cartTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              surfaceColor: AppColors.headerHomeSurface,
              child: HeaderMobileActions(
                cartCount: 3,
                notificationCount: 12,
                onCartTap: () => cartTaps++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      await tester.tap(
        find
            .descendant(
              of: find.byType(HeaderMobileActions),
              matching: find.byType(HeaderActionButton),
            )
            .first,
      );
      expect(cartTaps, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
