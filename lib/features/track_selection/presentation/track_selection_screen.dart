import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/db/app_database.dart';
import '../../navigation/logic/navigation_providers.dart';
import 'widgets/track_card.dart';

/// Track Selection Screen - Shows available tracks and basecamps for a mountain
class TrackSelectionScreen extends ConsumerWidget {
  final MountainRegion mountain;

  const TrackSelectionScreen({super.key, required this.mountain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailsAsync = ref.watch(activeTrailsProvider(mountain.id));
    final basecampsAsync = ref.watch(basecampsProvider(mountain.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mountain.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select your track',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Offline indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0df259).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0df259).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.offline_pin,
                            color: Color(0xFF0df259), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'OFFLINE',
                          style: TextStyle(
                            color: Color(0xFF0df259),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TRACKS SECTION
            _buildSectionHeader('AVAILABLE TRACKS', Icons.route),

            const SizedBox(height: 12),

            Expanded(
              child: trailsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0df259)),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (trails) {
                  if (trails.isEmpty) {
                    return _buildEmptyState('No tracks available');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: trails.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trail = trails[index];
                      return TrackCard(
                        trail: trail,
                        onTap: () => _navigateToMap(context, ref, trail),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined,
              size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  void _navigateToMap(BuildContext context, WidgetRef ref, Trail trail) {
    // Set active mountain and trail
    ref.read(activeMountainIdProvider.notifier).state = mountain.id;

    Navigator.pushNamed(
      context,
      '/map',
      arguments: {
        'mountain': mountain,
        'trail': trail,
      },
    );
  }
}
