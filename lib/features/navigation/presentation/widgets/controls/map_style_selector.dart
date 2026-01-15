import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/navigation_providers.dart';

class MapStyleSelector extends ConsumerWidget {
  const MapStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(mapStyleProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("SELECT MAP LAYER",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildOption(ref, MapLayerType.osm, "OSM", Icons.public,
                  currentStyle == MapLayerType.osm),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.cyclOsm, "CYCL",
                  Icons.directions_bike, currentStyle == MapLayerType.cyclOsm),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.openTopo, "TOPO", Icons.terrain,
                  currentStyle == MapLayerType.openTopo),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.vector, "VECT", Icons.map,
                  currentStyle == MapLayerType.vector),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOption(WidgetRef ref, MapLayerType type, String label,
      IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(mapStyleProvider.notifier).state = type,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0df259).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF0df259)
                    : Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? const Color(0xFF0df259) : Colors.white,
                  size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF0df259) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
