// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:forui/forui.dart';
import '../../test_scaffold.dart';

void main() {
  late FPopoverController controller;

  setUp(() => controller = FPopoverController(vsync: const TestVSync()));

  tearDown(() => controller.dispose());

  group('FPopover', () {
    testWidgets('tap outside hides popover', (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: FPopover(
            controller: controller,
            popoverBuilder: (context, style, _) => const Text('popover'),
            child: FButton(onPress: controller.toggle, child: const Text('target')),
          ),
        ),
      );

      await tester.tap(find.text('target'));
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsNothing);
    });

    testWidgets('tap outside does not hide popover', (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: FPopover(
            controller: controller,
            hideOnTapOutside: FHidePopoverRegion.none,
            popoverBuilder: (context, style, _) => const Text('popover'),
            child: FButton(onPress: controller.toggle, child: const Text('target')),
          ),
        ),
      );

      await tester.tap(find.text('target'));
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);
    });

    testWidgets('tap button when popover is open and FHidePopoverRegion.excludeTarget remains open', (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: FPopover(
            controller: controller,
            hideOnTapOutside: FHidePopoverRegion.excludeTarget,
            popoverBuilder: (context, style, _) => const Text('popover'),
            child: Row(
              children: [
                const Text('other'),
                FButton(onPress: controller.toggle, child: const Text('target')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('target'));
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);

      await tester.tap(find.text('other'));
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsNothing);
    });

    testWidgets('tap button when popover is open and FHidePopoverRegion.anywhere closes it', (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: FPopover(
            controller: controller,
            popoverBuilder: (context, style, _) => const Text('follower'),
            child: Row(
              children: [
                const Text('other'),
                FButton(onPress: controller.toggle, child: const Text('target')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('target'));
      await tester.pumpAndSettle();

      expect(find.text('follower'), findsOneWidget);

      await tester.tap(find.text('other'));
      await tester.pumpAndSettle();

      expect(find.text('follower'), findsNothing);
    });
  });

  group('FPopover.automatic', () {
    testWidgets('shown', (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: FPopover.automatic(
            controller: controller,
            popoverBuilder: (context, style, _) => const Text('popover'),
            child: Container(color: Colors.black, height: 10, width: 10),
          ),
        ),
      );

      await tester.tap(find.byType(Container).last);
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(find.text('popover'), findsNothing);
    });
  });

  group('focus', () {
    testWidgets("focuses on popover's children", (tester) async {
      await tester.pumpWidget(
        TestScaffold.app(
          child: Column(
            children: [
              FPopover.automatic(
                popoverBuilder: (context, style, _) => Row(
                  children: [
                    FButton(onPress: () {}, child: const Text('1')),
                    FButton(onPress: () {}, child: const Text('2')),
                    FButton(onPress: () {}, child: const Text('3')),
                  ],
                ),
                child: Container(color: Colors.black, height: 10, width: 10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FButton(onPress: () {}, child: const Text('Underneath')),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(Container).last);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(Focus.of(tester.element(find.text('3'))).hasFocus, true);
    });
  });

  group('state', () {
    testWidgets('update controller', (tester) async {
      final first = autoDispose(FPopoverController(vsync: tester));
      await tester.pumpWidget(
        TestScaffold(
          child: FPopover(
            controller: first,
            popoverBuilder: (context, value, child) => const SizedBox(),
            child: Container(color: Colors.black, height: 10, width: 10),
          ),
        ),
      );

      expect(first.hasListeners, false);
      expect(first.disposed, false);

      final second = autoDispose(FPopoverController(vsync: tester));
      await tester.pumpWidget(
        TestScaffold(
          child: FPopover(
            controller: second,
            popoverBuilder: (context, value, child) => const SizedBox(),
            child: Container(color: Colors.black, height: 10, width: 10),
          ),
        ),
      );

      expect(first.hasListeners, false);
      expect(first.disposed, false);
      expect(second.hasListeners, false);
      expect(second.disposed, false);
    });

    testWidgets('dispose controller', (tester) async {
      final controller = autoDispose(FPopoverController(vsync: tester));
      await tester.pumpWidget(
        TestScaffold(
          child: FPopover(
            controller: controller,
            popoverBuilder: (context, value, child) => const SizedBox(),
            child: Container(color: Colors.black, height: 10, width: 10),
          ),
        ),
      );

      expect(controller.hasListeners, false);
      expect(controller.disposed, false);

      await tester.pumpWidget(TestScaffold(child: const SizedBox()));

      expect(controller.hasListeners, false);
      expect(controller.disposed, false);
    });
  });
}
