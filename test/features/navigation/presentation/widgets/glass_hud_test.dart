import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/glass_hud.dart';

void main() {
  testWidgets('CockpitHud displays altitude and bearing', (WidgetTester tester) async {
    // Arrange
    const altitude = 1234.0;
    const bearing = 45.0;

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CockpitHud(
            altitude: altitude,
            bearing: bearing,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('1234 m'), findsOneWidget);
    expect(find.text('45°'), findsOneWidget);
  });

  testWidgets('CockpitHud displays speed when provided', (WidgetTester tester) async {
    // Arrange
    const altitude = 1000.0;
    const bearing = 90.0;
    const speed = 10.0; // 10 m/s = 36 km/h

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CockpitHud(
            altitude: altitude,
            bearing: bearing,
            speed: speed,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('36.0 km/h'), findsOneWidget);
  });
}
