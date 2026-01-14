import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: PanduApp(),
    ),
  );
}

class PanduApp extends StatelessWidget {
  const PanduApp({super.key});

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
