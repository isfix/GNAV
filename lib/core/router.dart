import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/track_selection/presentation/track_selection_screen.dart';
import '../features/track_selection/presentation/stitch_home_screen.dart';
import '../features/track_selection/presentation/stitch_track_selection_screen.dart';
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

    // Stitch Track Selection Screen (new premium design)
    GoRoute(
      path: '/tracks',
      builder: (context, state) => const StitchTrackSelectionScreen(),
    ),

    // Stitch Map Screen (Merbabu_6 Design)
    GoRoute(
      path: '/map',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final trail = extra?['trail'] as Trail?;
        return StitchMapScreen(trail: trail);
      },
    ),

    // Legacy Home (Backup)
    GoRoute(
      path: '/legacy',
      builder: (context, state) => const HomeScreen(),
    ),

    // Track Selection Screen (Legacy)
    GoRoute(
      path: '/legacy-tracks',
      builder: (context, state) {
        final mountain = state.extra as MountainRegion;
        return TrackSelectionScreen(mountain: mountain);
      },
    ),
  ],
);
