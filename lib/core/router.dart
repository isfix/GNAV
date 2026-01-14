import 'package:go_router/go_router.dart';
import '../../features/navigation/presentation/offline_map_screen.dart';
import '../../features/region_manager/presentation/region_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/regions',
      builder: (context, state) => const RegionListScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const OfflineMapScreen(),
    ),
  ],
);
