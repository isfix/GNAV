import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/presentation/widgets/stitch/stitch_theme.dart';
import '../../navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import '../../navigation/presentation/widgets/stitch/stitch_typography.dart';
import '../../navigation/logic/navigation_providers.dart';
import '../../../data/local/db/app_database.dart';

/// Premium Track Selection Screen matching pandu_track_selection_merbabu design
class StitchTrackSelectionScreen extends ConsumerWidget {
  const StitchTrackSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mountainId = ref.watch(activeMountainIdProvider);
    final trailsAsync = ref.watch(activeTrailsProvider(mountainId));

    return Scaffold(
      backgroundColor: StitchTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: StitchTheme.glassLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: StitchTheme.borderLight),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mount Merbabu',
                          style: StitchTypography.titleLarge,
                        ),
                        Text(
                          'Select your track',
                          style: StitchTypography.subtitle,
                        ),
                      ],
                    ),
                  ),
                  // Offline badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: StitchTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: StitchTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.offline_pin,
                          color: StitchTheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OFFLINE',
                          style: StitchTypography.badge.copyWith(
                            color: StitchTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, color: StitchTheme.textDim, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'AVAILABLE TRACKS',
                    style: StitchTypography.labelTiny.copyWith(
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Track list
            Expanded(
              child: trailsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: StitchTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: StitchTheme.danger),
                  ),
                ),
                data: (trails) {
                  if (trails.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trails.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _StitchTrackCard(
                        trail: trails[index],
                        onTap: () =>
                            _navigateToMap(context, ref, trails[index]),
                      );
                    },
                  );
                },
              ),
            ),

            // Home indicator
            Center(
              child: Container(
                width: 128,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: StitchTheme.tacticalGray,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 48,
            color: StitchTheme.textSubtle,
          ),
          const SizedBox(height: 12),
          Text(
            'No tracks available',
            style: StitchTypography.bodyMedium.copyWith(
              color: StitchTheme.textDim,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMap(BuildContext context, WidgetRef ref, Trail trail) {
    context.push('/map', extra: {'trail': trail});
  }
}

/// Premium track card widget matching reference design
class _StitchTrackCard extends StatelessWidget {
  final Trail trail;
  final VoidCallback onTap;

  const _StitchTrackCard({
    required this.trail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = (trail.distance / 1000).toStringAsFixed(1);
    final elevationM = trail.elevationGain.toInt();

    // Extract surface info from first point (if available)
    String surface = 'Unknown Surface';
    if (trail.geometryJson.isNotEmpty) {
      final firstPoint = trail.geometryJson.first;
      if (firstPoint.surface != null) {
        // Format: "unpaved" -> "Unpaved"
        surface = firstPoint.surface!.substring(0, 1).toUpperCase() +
            firstPoint.surface!.substring(1);
        // Clean up common OSM tags
        surface = surface.replaceAll('_', ' ');
      }
    }

    return StitchGlassPanel(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(16),
      backgroundColor: StitchTheme.glassLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Trail icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StitchTheme.primary.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.hiking,
                  color: StitchTheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Trail info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.name,
                      style:
                          StitchTypography.displaySmall.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStat(Icons.straighten, '$distanceKm km'),
                        const SizedBox(width: 16),
                        _buildStat(Icons.trending_up, '+$elevationM m'),
                      ],
                    ),
                  ],
                ),
              ),

              // Start button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: StitchTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'START',
                  style: StitchTypography.buttonSmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: StitchTheme.borderSubtle, height: 1),
          const SizedBox(height: 12),

          // Difficulty & Surface Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 5-Scale Difficulty
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIFFICULTY',
                      style: StitchTypography.labelMicro
                          .copyWith(color: StitchTheme.textDim)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDifficultyDots(trail.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        _getDifficultyLabel(trail.difficulty),
                        style: StitchTypography.labelTiny.copyWith(
                          color: _getDifficultyColor(trail.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Surface Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SURFACE',
                      style: StitchTypography.labelMicro
                          .copyWith(color: StitchTheme.textDim)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.terrain,
                          size: 12, color: StitchTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        surface,
                        style: StitchTypography.labelTiny
                            .copyWith(color: StitchTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: StitchTheme.textDim),
        const SizedBox(width: 4),
        Text(
          value,
          style: StitchTypography.monoSmall,
        ),
      ],
    );
  }

  Widget _buildDifficultyDots(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isActive = index < difficulty.clamp(1, 5);
        final color = _getDifficultyColor(difficulty);

        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(left: index > 0 ? 3 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : StitchTheme.tacticalGray,
          ),
        );
      }),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 1) return Colors.cyan;
    if (difficulty <= 2) return StitchTheme.primary;
    if (difficulty <= 3) return Colors.yellow;
    if (difficulty <= 4) return StitchTheme.warning;
    return StitchTheme.danger;
  }

  String _getDifficultyLabel(int difficulty) {
    if (difficulty <= 1) return 'EASY';
    if (difficulty <= 2) return 'MODERATE';
    if (difficulty <= 3) return 'HARD';
    if (difficulty <= 4) return 'SEVERE';
    return 'EXTREME';
  }
}
