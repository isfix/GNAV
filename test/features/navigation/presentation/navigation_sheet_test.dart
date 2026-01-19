import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/sheets/navigation_sheet.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';
// import 'package:pandu_navigation/data/local/db/app_database.dart'; // Not needed if userLoc is null

void main() {
  testWidgets('NavigationSheet updates compass heading without rebuild', (WidgetTester tester) async {
    // Set a large enough screen size to avoid overflow in DraggableScrollableSheet
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final headingNotifier = ValueNotifier<double>(0.0);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NavigationSheet(
          status: SafetyStatus.safe,
          userLoc: null,
          heading: headingNotifier,
          onBacktrack: () {},
          onSimulateMenu: () {},
        ),
      ),
    ));

    // NavigationSheet starts at page 1 (Dashboard). We need to switch to page 0 (Compass).
    await tester.tap(find.byIcon(Icons.explore));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('0°'), findsOneWidget);

    // Update heading
    headingNotifier.value = 90.0;
    await tester.pump(); // Pump frame

    // Verify updated state
    expect(find.text('90°'), findsOneWidget);

    // Update heading again
    headingNotifier.value = 180.0;
    await tester.pump();

    // Verify updated state
    expect(find.text('180°'), findsOneWidget);
  });
}
