import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/logic/navigation_providers.dart';
import '../../../data/local/db/app_database.dart';
import '../../navigation/presentation/widgets/stitch/stitch_theme.dart';
import 'widgets/mountain_card.dart';

/// Home Screen - Shows list of available mountains
/// This is the new entry point for the app (replacing map-first approach)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mountainsAsync = ref.watch(allMountainsProvider);

    return Scaffold(
      backgroundColor: StitchTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchTheme.primary,
                          boxShadow: StitchTheme.neonGlow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PANDU',
                        style: TextStyle(
                          color: StitchTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Where will you\nclimb today?',
                    style: TextStyle(
                      color: StitchTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.terrain,
                      color: StitchTheme.textSubtle, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'AVAILABLE MOUNTAINS',
                    style: TextStyle(
                      color: StitchTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // MOUNTAIN LIST
            Expanded(
              child: mountainsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: StitchTheme.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: StitchTheme.danger)),
                ),
                data: (mountains) {
                  if (mountains.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: mountains.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final mountain = mountains[index];
                      return MountainCard(
                        mountain: mountain,
                        onTap: () =>
                            _navigateToTrackSelection(context, mountain),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_outlined,
              size: 64, color: StitchTheme.textSubtle),
          const SizedBox(height: 16),
          Text(
            'No mountains available',
            style: TextStyle(color: StitchTheme.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your data connection',
            style: TextStyle(color: StitchTheme.textSubtle, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _navigateToTrackSelection(
      BuildContext context, MountainRegion mountain) {
    context.push('/tracks', extra: mountain);
  }
}
