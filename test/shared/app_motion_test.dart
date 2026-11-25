import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/shared/motion/app_hero.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';
import 'package:serba_jaya_mobile/shared/motion/app_overlays.dart';
import 'package:serba_jaya_mobile/shared/motion/app_page_transitions.dart';
import 'package:serba_jaya_mobile/shared/motion/app_press_feedback.dart';
import 'package:serba_jaya_mobile/shared/motion/app_tab_transition.dart';

void main() {
  testWidgets('dialog fades and scales above a dimmed, mounted page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        builder: (context) => TextButton(
          onPressed: () => unawaited(
            showAppDialog<void>(
              context: context,
              builder: (_) => const Dialog(child: Text('Dialog fixture')),
            ),
          ),
          child: const Text('Open dialog'),
        ),
      ),
    );
    await tester.tap(find.text('Open dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final dialog = find.byType(Dialog);
    final scale = tester.widget<ScaleTransition>(
      find.ancestor(of: dialog, matching: find.byType(ScaleTransition)).first,
    );
    expect(
      scale.scale.value,
      inExclusiveRange(AppMotion.dialogStartScale, 1.0),
    );
    expect(find.text('Open dialog'), findsOneWidget);
    final route = ModalRoute.of(tester.element(dialog))!;
    expect(route.opaque, isFalse);
    expect(route.barrierColor, AppMotion.barrierColor);
    expect(route.transitionDuration, AppMotion.dialog);
    expect(route.reverseTransitionDuration, AppMotion.dialogReverse);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
  });

  testWidgets('bottom sheet slides, avoids keyboard, and dismisses by drag', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const sheetKey = ValueKey('sheet-content');
    await tester.pumpWidget(
      _host(
        builder: (context) => TextButton(
          onPressed: () => unawaited(
            showAppBottomSheet<void>(
              context: context,
              topRadius: const Radius.circular(24),
              builder: (_) => const SizedBox(
                key: sheetKey,
                width: double.infinity,
                height: 180,
              ),
            ),
          ),
          child: const Text('Open sheet'),
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final sheet = find.byKey(sheetKey);
    final initialY = tester.getTopLeft(sheet).dy;
    await tester.pumpAndSettle();
    final settledY = tester.getTopLeft(sheet).dy;
    expect(settledY, lessThan(initialY));
    final route = ModalRoute.of(tester.element(sheet))!;
    expect(route.barrierColor, AppMotion.barrierColor);
    expect(route.transitionDuration, AppMotion.sheet);
    expect(route.reverseTransitionDuration, AppMotion.sheet);

    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(sheet).dy, settledY - 180);
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.dragFrom(tester.getCenter(sheet), const Offset(0, 210));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
  });

  testWidgets('tabs preserve scroll offset and repeated switches settle', (
    tester,
  ) async {
    final index = ValueNotifier(0);
    final scroll = ScrollController();
    addTearDown(index.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      _host(
        builder: (_) => ValueListenableBuilder<int>(
          valueListenable: index,
          builder: (_, value, _) => AppTabTransition(
            index: value,
            children: [
              ListView(
                controller: scroll,
                children: const [SizedBox(height: 1500)],
              ),
              const Text('Other tab'),
            ],
          ),
        ),
      ),
    );
    scroll.jumpTo(340);
    for (final tab in [1, 0, 1, 0]) {
      index.value = tab;
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(scroll.offset, 340);
    expect(find.text('Other tab'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduce motion skips page, tab, sheet, and dialog animations', (
    tester,
  ) async {
    final tab = ValueNotifier(0);
    addTearDown(tab.dispose);
    await tester.pumpWidget(
      _host(
        reduced: true,
        builder: (context) => Column(
          children: [
            TextButton(
              onPressed: () => unawaited(
                Navigator.of(context).push(
                  const AppTransitionPage<void>(
                    child: Scaffold(body: Text('Page fixture')),
                  ).createRoute(context),
                ),
              ),
              child: const Text('Open page'),
            ),
            TextButton(
              onPressed: () => unawaited(
                showAppDialog<void>(
                  context: context,
                  builder: (_) => const Dialog(child: Text('Dialog fixture')),
                ),
              ),
              child: const Text('Open dialog'),
            ),
            TextButton(
              onPressed: () => unawaited(
                showAppBottomSheet<void>(
                  context: context,
                  topRadius: const Radius.circular(24),
                  builder: (_) => const Text('Sheet fixture'),
                ),
              ),
              child: const Text('Open sheet'),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: tab,
                builder: (_, index, _) => AppTabTransition(
                  index: index,
                  children: const [Text('First tab'), Text('Second tab')],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    tab.value = 1;
    await tester.pump();
    expect(find.text('First tab'), findsNothing);
    expect(find.text('Second tab'), findsOneWidget);
    for (final (label, content) in [
      ('Open page', 'Page fixture'),
      ('Open dialog', 'Dialog fixture'),
      ('Open sheet', 'Sheet fixture'),
    ]) {
      await tester.tap(find.text(label));
      await tester.pump();
      final element = tester.element(find.text(content));
      final route = ModalRoute.of(element)!;
      expect(route.transitionDuration, Duration.zero);
      expect(route.reverseTransitionDuration, Duration.zero);
      Navigator.of(element).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('press changes visual scale while keeping the button enabled', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _host(
        builder: (_) => AppPressFeedback(
          builder: (_, states) => FilledButton(
            statesController: states,
            onPressed: () => presses++,
            child: const Text('Press'),
          ),
        ),
      ),
    );
    final button = find.byType(FilledButton);
    final transform = find
        .ancestor(of: button, matching: find.byType(Transform))
        .first;
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await tester.pump(AppMotion.press);
    expect(
      tester.widget<Transform>(transform).transform.storage[0],
      AppMotion.pressedScale,
    );
    expect(tester.widget<Transform>(transform).transformHitTests, isFalse);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<Transform>(transform).transform.storage[0], 1);
    expect(presses, 1);
  });

  testWidgets(
    'Hero tags include the source and flights respect reduce motion',
    (tester) async {
      await tester.pumpWidget(
        _host(
          reduced: true,
          builder: (_) => const Column(
            children: [
              AppHero(
                tag: (source: 'home-featured', itemId: 1),
                child: Text('Featured'),
              ),
              AppHero(
                tag: (source: 'home-results', itemId: 1),
                child: Text('Results'),
              ),
            ],
          ),
        ),
      );
      final heroes = tester.widgetList<Hero>(find.byType(Hero));
      expect(heroes.map((hero) => hero.tag).toSet(), hasLength(2));
      expect(
        tester
            .widgetList<HeroMode>(find.byType(HeroMode))
            .where((mode) => !mode.enabled),
        hasLength(2),
      );
    },
  );
}

Widget _host({required WidgetBuilder builder, bool reduced = false}) =>
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
      home: Scaffold(body: Builder(builder: builder)),
    );
