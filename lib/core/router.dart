import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/track_selection/presentation/track_selection_screen.dart';
import '../features/track_selection/presentation/stitch_home_screen.dart';
import '../features/navigation/presentation/stitch_map_screen.dart';
import '../data/local/db/app_database.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Stitch Home Screen (Stitch Pandu Design)
    GoRoute(
      path: '/',
      builder: (context, state) => const StitchHomeScreen(),
    ),

    // Stitch Map Screen (Merbabu_6 Design)
    GoRoute(
      path: '/map',
      builder: (context, state) {
        // Can unpack extra args if needed, but StitchMapScreen handles itself for now
        // final args = state.extra as Map<String, dynamic>?;
        return const StitchMapScreen();
      },
    ),

    // Legacy Home (Backup)
    GoRoute(
      path: '/legacy',
      builder: (context, state) => const HomeScreen(),
    ),

    // Track Selection Screen (Legacy)
    GoRoute(
      path: '/tracks',
      builder: (context, state) {
        final mountain = state.extra as MountainRegion;
        return TrackSelectionScreen(mountain: mountain);
      },
    ),
  ],
);
