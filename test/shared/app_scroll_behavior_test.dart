import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/core/ui/scroll/app_scroll_behavior.dart';

void main() {
  testWidgets(
    'long form bounces at both edges and returns to its bounds',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const AppScrollBehavior(),
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              child: const SizedBox(height: 2200, width: double.infinity),
            ),
          ),
        ),
      );

      expect(controller.position.physics, isA<BouncingScrollPhysics>());
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);
      expect(find.byType(StretchingOverscrollIndicator), findsNothing);

      Future<void> overscroll(double drag, double edge) async {
        final gesture = await tester.startGesture(const Offset(300, 250));
        await gesture.moveBy(Offset(0, drag));
        await tester.pump();
        expect(
          controller.offset,
          drag > 0 ? lessThan(edge) : greaterThan(edge),
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(controller.offset, closeTo(edge, 0.01));
      }

      await overscroll(150, 0);
      final bottom = controller.position.maxScrollExtent;
      controller.jumpTo(bottom);
      await tester.pump();
      await overscroll(-150, bottom);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'horizontal fling keeps its momentum without scrolling the surrounding slivers',
    (tester) async {
      final horizontal = ScrollController();
      final vertical = ScrollController();
      addTearDown(horizontal.dispose);
      addTearDown(vertical.dispose);
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const AppScrollBehavior(),
          home: Scaffold(
            body: CustomScrollView(
              controller: vertical,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      controller: horizontal,
                      scrollDirection: Axis.horizontal,
                      itemCount: 100,
                      itemExtent: 120,
                      itemBuilder: (_, index) => Text('Item $index'),
                    ),
                  ),
                ),
                SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: 100,
                  itemBuilder: (_, index) => Text('Produk $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(horizontal.position.physics, isA<BouncingScrollPhysics>());
      expect(vertical.position.physics, isA<BouncingScrollPhysics>());
      expect(find.text('Item 99'), findsNothing);
      expect(find.text('Produk 99'), findsNothing);
      await tester.fling(find.byType(ListView), const Offset(-300, 0), 1200);
      final releasedAt = horizontal.offset;
      await tester.pumpAndSettle();
      expect(horizontal.offset, greaterThan(releasedAt));
      expect(vertical.offset, 0);

      await tester.dragFrom(const Offset(400, 320), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(vertical.offset, greaterThan(0));
    },
  );

  testWidgets('short content stays still unless a refresh surface opts in', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var refreshes = 0;

    Future<void> mount({required bool refreshable}) => tester.pumpWidget(
      MaterialApp(
        scrollBehavior: AppScrollBehavior(alwaysScrollable: refreshable),
        home: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async => refreshes++,
            child: ListView(
              controller: controller,
              children: const [SizedBox(height: 60, child: Text('Konten'))],
            ),
          ),
        ),
      ),
    );

    await mount(refreshable: false);
    await tester.dragFrom(const Offset(300, 65), const Offset(0, 470));
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    expect(refreshes, 0);

    await mount(refreshable: true);
    await tester.dragFrom(const Offset(300, 65), const Offset(0, 470));
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });
}
