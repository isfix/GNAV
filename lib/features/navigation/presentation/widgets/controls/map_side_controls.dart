import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/navigation_providers.dart';
import '../atoms/glass_icon_button.dart';

class MapSideControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;
  final VoidCallback onLayer;
  final VoidCallback onLoadRoute;

  const MapSideControls(
      {super.key,
      required this.onZoomIn,
      required this.onZoomOut,
      required this.onCenter,
      required this.onLayer,
      required this.onLoadRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassIconButton(
          icon: Icons.add,
          onTap: onZoomIn,
          tooltip: "Zoom In",
          semanticLabel: "Zoom In",
        ),
        const SizedBox(height: 12),
        GlassIconButton(
          icon: Icons.remove,
          onTap: onZoomOut,
          tooltip: "Zoom Out",
          semanticLabel: "Zoom Out",
        ),
        const SizedBox(height: 12),
        GlassIconButton(
          icon: Icons.near_me,
          onTap: onCenter,
          isPrimary: true,
          tooltip: "Re-center Map",
          semanticLabel: "Re-center Map",
        ),
        const SizedBox(height: 12),
        GlassIconButton(
          icon: Icons.layers,
          onTap: onLayer,
          tooltip: "Map Layers",
          semanticLabel: "Map Layers",
        ),
        const SizedBox(height: 12),
        GlassIconButton(
          icon: Icons.flag,
          onTap: onLoadRoute, // Load Route
          tooltip: "Load Route",
          semanticLabel: "Load Route",
        ),
        const SizedBox(height: 12),
        // Tactical Mode Toggle
        Consumer(builder: (context, ref, child) {
          final isTactical = ref.watch(isTacticalModeProvider);
          return GlassIconButton(
            icon: Icons.nightlight_round,
            onTap: () => ref
                .read(isTacticalModeProvider.notifier)
                .update((state) => !state),
            isPrimary: isTactical, // Highlight when active
            tooltip: "Toggle Tactical Mode",
            semanticLabel: isTactical
                ? "Disable Tactical Mode"
                : "Enable Tactical Mode",
          );
        }),
      ],
    );
  }
}
