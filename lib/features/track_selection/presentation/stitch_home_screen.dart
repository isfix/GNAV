import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/presentation/widgets/stitch/stitch_theme.dart';
import '../../navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import '../../navigation/presentation/widgets/stitch/stitch_typography.dart';
import '../../navigation/logic/navigation_providers.dart';

class StitchHomeScreen extends ConsumerWidget {
  const StitchHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StitchTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: StitchTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: StitchTheme.neonGlow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'PANDU',
                        style: StitchTypography.labelSmall.copyWith(
                          color: StitchTheme.primary,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Where will you\n'),
                        TextSpan(
                          text: 'climb today?',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                    style: StitchTypography.displayLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // "Available Mountains" Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  const Icon(Icons.terrain, size: 14, color: Colors.white38),
                  const SizedBox(width: 8),
                  Text(
                    'AVAILABLE MOUNTAINS',
                    style: StitchTypography.labelSmall.copyWith(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: Colors.white38),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                children: [
                  // Merbabu (Active)
                  _buildMountainCard(
                    context,
                    name: 'Mount Merbabu',
                    icon: Icons.terrain,
                    isActive: true,
                    isOfflineReady: true,
                    onTap: () {
                      ref.read(activeMountainIdProvider.notifier).state =
                          'merbabu';
                      context.push('/map');
                    },
                  ),
                  const SizedBox(height: 20),
                  // Semeru (Disabled)
                  _buildMountainCard(
                    context,
                    name: 'Mount Semeru',
                    icon: Icons.terrain,
                    isActive: false,
                    isOfflineReady: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMountainCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required bool isActive,
    required bool isOfflineReady,
    VoidCallback? onTap,
  }) {
    return StitchGlassPanel(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(20),
      hasGlow: isActive,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive
                    ? StitchTheme.primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive
                      ? StitchTheme.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isActive ? StitchTheme.neonGlow : null,
              ),
              child: Icon(
                icon,
                color: isActive ? StitchTheme.primary : Colors.white38,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                        StitchTypography.displayMedium.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  if (isActive)
                    Row(
                      children: [
                        _buildBadge('OFFLINE', StitchTheme.primary),
                        const SizedBox(width: 8),
                        _buildBadge('MERBABU', Colors.white38, isOutline: true),
                      ],
                    )
                  else
                    Text(
                      'COMING SOON',
                      style: StitchTypography.labelSmall
                          .copyWith(color: Colors.white38),
                    ),
                ],
              ),
            ),

            // Chevron
            Icon(
              isActive ? Icons.chevron_right : Icons.lock,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOutline
              ? Colors.white.withOpacity(0.1)
              : color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isOutline ? Colors.white38 : color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
