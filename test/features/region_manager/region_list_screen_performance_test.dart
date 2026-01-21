import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';
import 'package:pandu_navigation/core/services/seeding_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/features/region_manager/presentation/region_list_screen.dart';

// Fake SeedingService to avoid actual asset loading and DB operations
class FakeSeedingService extends SeedingService {
  FakeSeedingService(AppDatabase db) : super(db);

  @override
  Future<void> seedMerbabu() async {
    // No-op for testing
  }
}

void main() {
  testWidgets('RegionListScreen download performance optimized test',
      (WidgetTester tester) async {
    // 1. Setup
    final db = AppDatabase(NativeDatabase.memory());
    final fakeSeedingService = FakeSeedingService(db);

    final router = GoRouter(
      initialLocation: '/regions',
      routes: [
        GoRoute(
          path: '/regions',
          builder: (context, state) => const RegionListScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seedingServiceProvider.overrideWithValue(fakeSeedingService),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // 2. Measure
    final merbabuFinder = find.text('Mount Merbabu');
    expect(merbabuFinder, findsOneWidget);

    // Tap the card to trigger download
    await tester.tap(merbabuFinder);
    await tester.pump(); // Trigger the setState and start the future

    // Advance time by 100ms.
    // Since the delay is removed, it should complete almost instantly.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify navigation occurred
    expect(find.text('Home'), findsOneWidget);

    // Cleanup
    await db.close();
  });
}
