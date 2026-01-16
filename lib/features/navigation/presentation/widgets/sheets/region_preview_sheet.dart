import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../logic/navigation_providers.dart';

class RegionPreviewSheet extends ConsumerWidget {
  final dynamic region; // MountainRegion
  final Function(LatLng?) onAction;

  const RegionPreviewSheet(
      {super.key, required this.region, required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch POIs for this region (to find Basecamps)
    final poisAsync = ref.watch(activePoisProvider(region.id));

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 600, // Fixed height for list
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HANDLE
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // HEADER IMAGE
              Expanded(
                flex: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/mountains/${region.id}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                              child: Icon(Icons.terrain,
                                  size: 64, color: Colors.white10))),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Colors.transparent,
                            const Color(0xFF121212).withOpacity(0.95)
                          ])),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(region.name.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF0df259), size: 14),
                              const SizedBox(width: 4),
                              Text("CENTRAL JAVA, INDONESIA",
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                      letterSpacing: 1.2))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // BASECAMPS LIST
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SELECT BASECAMP",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: poisAsync.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0df259))),
                            error: (e, s) => Center(
                                child: Text("Failed to load basecamps: $e",
                                    style: const TextStyle(
                                        color: Colors.white30))),
                            data: (pois) {
                              // Filter for Basecamps (Type 0)
                              final basecamps =
                                  pois.where((p) => p.type == 0).toList();

                              if (basecamps.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.warning_amber,
                                        color: Colors.white30, size: 48),
                                    const SizedBox(height: 8),
                                    const Text("No Basecamps Found",
                                        style:
                                            TextStyle(color: Colors.white30)),
                                    const SizedBox(height: 24),
                                    // Fallback generic enter
                                    GestureDetector(
                                      onTap: () =>
                                          onAction(null), // Default move
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF0df259),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Text("ENTER MAP ANYWAY",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                );
                              }

                              return ListView.separated(
                                itemCount: basecamps.length,
                                separatorBuilder: (c, i) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final bc = basecamps[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Move specific to basecamp
                                      onAction(LatLng(bc.lat, bc.lng));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.1))),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF0df259)
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle),
                                            child: const Icon(Icons.home_work,
                                                color: Color(0xFF0df259),
                                                size: 20),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(bc.name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "Elevation: ${bc.elevation}m",
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              color: Colors.white24, size: 14)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
