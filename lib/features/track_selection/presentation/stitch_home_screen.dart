import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/presentation/widgets/stitch/stitch_theme.dart';
import '../../navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import '../../navigation/presentation/widgets/stitch/stitch_typography.dart';
import '../../navigation/logic/navigation_providers.dart';
import '../../../core/services/config_service.dart';

class StitchHomeScreen extends ConsumerWidget {
  const StitchHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: StitchTheme.backgroundDark,
      body: Stack(
        children: [
          // Background glow orb (top-left)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StitchTheme.primary.withOpacity(0.08),
                    StitchTheme.primary.withOpacity(0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo with animated glow
                      Row(
                        children: [
                          _AnimatedLogoDot(),
                          const SizedBox(width: 10),
                          Text(
                            'PANDU',
                            style: StitchTypography.labelSmall.copyWith(
                              color: StitchTheme.primary,
                              letterSpacing: 4.0,
                              fontSize: 11,
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
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                        style: StitchTypography.displayLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // "Available Mountains" Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Icon(Icons.terrain,
                          size: 14, color: StitchTheme.textSubtle),
                      const SizedBox(width: 8),
                      Text(
                        'AVAILABLE MOUNTAINS',
                        style: StitchTypography.labelTiny,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Mountain List
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final mountainsAsync = ref.watch(mountainsProvider);

                      return mountainsAsync.when(
                        data: (mountains) {
                          if (mountains.isEmpty) {
                            return Center(
                                child: Text('No mountains available',
                                    style: StitchTypography.bodyMedium));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            itemCount: mountains.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final mountain = mountains[index];
                              // Currently we assume all in config are 'active' or we check a flag.
                              // For now, let's treat them as active if present in JSON.
                              // Or check difficulty/status if added to JSON.
                              // mountains.json simplified version only has id/name/paths/difficulty.
                              final bool isActive = true;

                              return _buildMountainCard(
                                context,
                                ref,
                                name: mountain.name,
                                icon: Icons.terrain,
                                isActive: isActive,
                                isOfflineReady:
                                    true, // Assuming local config means offline ready
                                badgeText: mountain.difficulty.toUpperCase(),
                                onTap: () {
                                  ref
                                      .read(activeMountainIdProvider.notifier)
                                      .state = mountain.id;
                                  context.push('/tracks');
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(
                            child: Text('Error: $err',
                                style: StitchTypography.bodyMedium
                                    .copyWith(color: StitchTheme.danger))),
                      );
                    },
                  ),
                ),

                // Home indicator
                Center(
                  child: Container(
                    width: 134,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainCard(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required IconData icon,
    required bool isActive,
    required bool isOfflineReady,
    String? badgeText, // Added optional badge text (e.g. Difficulty)
    VoidCallback? onTap,
  }) {
    return StitchGlassPanel(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(20),
      hasGlow: isActive,
      backgroundColor: isActive ? null : StitchTheme.glass.withOpacity(0.3),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Row(
          children: [
            // Icon with glow background
            Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          StitchTheme.primary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
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
              ],
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: StitchTypography.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  if (isActive)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (isOfflineReady)
                          _buildBadge('OFFLINE', StitchTheme.primary),
                        if (badgeText != null)
                          _buildBadge(badgeText, StitchTheme.textSubtle,
                              isOutline: true),
                      ],
                    )
                  else
                    Text(
                      'COMING SOON',
                      style: StitchTypography.labelMicro
                          .copyWith(letterSpacing: 2),
                    ),
                ],
              ),
            ),

            // Chevron / Lock
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        style: StitchTypography.badge.copyWith(
          color: isOutline ? StitchTheme.textDim : color,
        ),
      ),
    );
  }
}

/// Animated pulsing logo dot
class _AnimatedLogoDot extends StatefulWidget {
  @override
  State<_AnimatedLogoDot> createState() => _AnimatedLogoDotState();
}

class _AnimatedLogoDotState extends State<_AnimatedLogoDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: StitchTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: StitchTheme.primary.withOpacity(_animation.value * 0.6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}
