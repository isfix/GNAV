import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/navigation_v2/screens/home_screen_v2.dart';
import '../features/track_selection/presentation/track_selection_screen.dart';
import '../features/navigation/presentation/offline_map_screen.dart';
import '../data/local/db/app_database.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Home Screen - Mountain List (NEW ENTRY POINT)
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // New Home Screen (for development)
    GoRoute(
      path: '/v2',
      builder: (context, state) => const HomeScreenV2(),
    ),

    // Track Selection Screen
    GoRoute(
      path: '/tracks',
      builder: (context, state) {
        final mountain = state.extra as MountainRegion;
        return TrackSelectionScreen(mountain: mountain);
      },
    ),

    // Map Screen (with selected mountain and trail)
    GoRoute(
      path: '/map',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final mountain = args?['mountain'] as MountainRegion?;
        final trail = args?['trail'] as Trail?;

        return OfflineMapScreen(
          mountainId: mountain?.id,
          trailId: trail?.id,
        );
      },
    ),
  ],
);
