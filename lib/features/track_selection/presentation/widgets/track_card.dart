import 'package:flutter/material.dart';
import '../../../../data/local/db/app_database.dart';

/// Premium track card widget
class TrackCard extends StatelessWidget {
  final Trail trail;
  final VoidCallback onTap;

  const TrackCard({
    super.key,
    required this.trail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = (trail.distance / 1000).toStringAsFixed(1);
    final elevationM = trail.elevationGain.toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF141414),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            // Trail icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0df259).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.hiking,
                color: Color(0xFF0df259),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStat(Icons.straighten, '$distanceKm km'),
                        const SizedBox(width: 16),
                        _buildStat(Icons.trending_up, '+$elevationM m'),
                        const SizedBox(width: 16),
                        _buildDifficultyIndicator(trail.difficulty),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Start button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0df259),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    final color = difficulty <= 2
        ? const Color(0xFF0df259)
        : difficulty <= 3
            ? Colors.orange
            : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < difficulty ? color : Colors.white12,
          ),
        );
      }),
    );
  }
}
