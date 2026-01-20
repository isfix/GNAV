import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/glass_hud.dart';

void main() {
  testWidgets('GlassFab has semantics and tooltip', (WidgetTester tester) async {
    // Arrange
    const icon = Icons.add;
    const label = 'Add Item';
    var tapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassFab(
            icon: icon,
            onTap: () => tapped = true,
            label: label,
          ),
        ),
      ),
    );

    // Assert
    // Check for Semantics
    expect(find.bySemanticsLabel(label), findsOneWidget);

    // Check for Tooltip
    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.text(label), findsOneWidget); // Tooltip message

    // Check Tap
    await tester.tap(find.byType(GlassFab));
    expect(tapped, isTrue);
  });

  testWidgets('GlassFab works without label', (WidgetTester tester) async {
    // Arrange
    const icon = Icons.remove;
    var tapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassFab(
            icon: icon,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Assert
    // Check that no Tooltip is present
    expect(find.byType(Tooltip), findsNothing);

    // Check Tap works
    await tester.tap(find.byType(GlassFab));
    expect(tapped, isTrue);
  });
}
