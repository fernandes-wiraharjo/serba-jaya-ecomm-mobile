import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/bottom_nav_item.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/navigation_badge.dart';

void main() {
  testWidgets('renders all five tabs and exposes a selected state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentDestination: AppDestination.home,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(BottomNavItem), findsNWidgets(5));
    for (final label in ['Beranda', 'Keranjang', 'Chat', 'Pesanan', 'Profil']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      find.byWidgetPredicate(
        (widget) => widget is BottomNavItem && widget.selected,
      ),
      findsOneWidget,
    );
  });

  testWidgets('preserves Figma icons and Chat center state across all tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final activeAssets = {
      AppDestination.home: AppAssets.navigationHomeActive,
      AppDestination.cart: AppAssets.navigationCartActive,
      AppDestination.chat: null,
      AppDestination.orders: AppAssets.navigationOrdersActive,
      AppDestination.profile: AppAssets.navigationProfileActive,
    };
    for (final destination in AppDestination.navigationTabs) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentDestination: destination,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final selectedItem = tester
          .widgetList<BottomNavItem>(find.byType(BottomNavItem))
          .singleWhere((item) => item.selected);
      expect(
        selectedItem.label,
        destination.label(
          AppLocalizations.of(tester.element(find.byType(AppBottomNavBar))),
        ),
      );
      expect(selectedItem.activeIconAsset, activeAssets[destination]);

      final chatItemFinder = find.byWidgetPredicate(
        (widget) => widget is BottomNavItem && widget.isCenterAction,
      );
      final chatItem = tester.widget<BottomNavItem>(chatItemFinder);
      expect(chatItem.selected, destination == AppDestination.chat);

      final brandingFinder = find.descendant(
        of: chatItemFinder,
        matching: find.byType(Image),
      );
      final branding = tester.widget<Image>(brandingFinder);
      expect(
        (branding.image as AssetImage).assetName,
        'assets/navigation/chat-branding-icon.png',
      );
      expect(branding.fit, BoxFit.contain);
      expect(branding.width, AppNavigationSize.chatBrandingIcon);
      expect(branding.height, AppNavigationSize.chatBrandingIcon);

      final chatButtonFinder = find.descendant(
        of: chatItemFinder,
        matching: find.byType(Container),
      );
      final chatButton = tester.widget<Container>(chatButtonFinder);
      final buttonDecoration = chatButton.decoration! as BoxDecoration;
      final buttonRect = tester.getRect(chatButtonFinder);
      expect(buttonDecoration.color, AppColors.navigationPrimary);
      expect(buttonDecoration.shape, BoxShape.circle);
      expect(buttonRect.width, AppNavigationSize.chatButton);
      expect(buttonRect.center.dx, 195);
      expect(
        tester.getRect(find.text('Chat')).top,
        greaterThan(buttonRect.bottom),
      );
      final buttonShadow = buttonDecoration.boxShadow!.single;
      expect(buttonShadow.color, AppColors.chatButtonShadow);
      expect(buttonShadow.offset, const Offset(0, 5));
      expect(buttonShadow.blurRadius, 10);

      final cradleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                AppColors.navigationCradle &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(cradleFinder, findsOneWidget);
      final cradleRect = tester.getRect(cradleFinder);
      expect(cradleRect.width, AppNavigationSize.chatCradle);
      expect(cradleRect.center, buttonRect.center);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('cart badge replaces the captured sample count dynamically', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentDestination: AppDestination.home,
            badgeCounts: const {AppDestination.cart: 12},
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('12'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentDestination: AppDestination.home,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('8'), findsNothing);
  });

  testWidgets('badge hides zero and caps large counts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NavigationBadge(count: 0)));
    expect(find.byType(Text), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(home: NavigationBadge(count: 105)),
    );
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('fits a compact viewport with larger text scale', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentDestination: AppDestination.chat,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
