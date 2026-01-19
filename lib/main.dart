import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'core/services/seeding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: PanduApp(),
    ),
  );
}

class PanduApp extends ConsumerStatefulWidget {
  const PanduApp({super.key});

  @override
  ConsumerState<PanduApp> createState() => _PanduAppState();
}

class _PanduAppState extends ConsumerState<PanduApp> {
  @override
  void initState() {
    super.initState();
    // ROBUST ASSET DISCOVERY: Seed data on app start
    // This ensures new assets are detected even if we start at HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seedingServiceProvider).discoverAndSeedAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pandu Navigation',
      theme: AppTheme.highContrastDark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
