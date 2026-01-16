import 'package:flutter/material.dart';
import '../../../../../data/local/db/app_database.dart';

/// Sheet showing mountain details when a mountain marker is tapped
class MountainDetailSheet extends StatelessWidget {
  final MountainRegion mountain;
  final List<PointOfInterest> basecamps;
  final void Function(PointOfInterest basecamp)? onBasecampTap;

  const MountainDetailSheet({
    super.key,
    required this.mountain,
    required this.basecamps,
    this.onBasecampTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Mountain Icon and Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.terrain, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mountain.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Central Java, Indonesia',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Download Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mountain.isDownloaded
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mountain.isDownloaded
                      ? Icons.cloud_done
                      : Icons.cloud_download,
                  size: 18,
                  color: mountain.isDownloaded ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  mountain.isDownloaded ? 'Map Downloaded' : 'Tap to Download',
                  style: TextStyle(
                    color: mountain.isDownloaded ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Basecamps Section
          if (basecamps.isNotEmpty) ...[
            Text(
              'Base Camps',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...basecamps.map((basecamp) => _BasecampTile(
                  basecamp: basecamp,
                  onTap: () => onBasecampTap?.call(basecamp),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No base camps available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BasecampTile extends StatelessWidget {
  final PointOfInterest basecamp;
  final VoidCallback? onTap;

  const _BasecampTile({
    required this.basecamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.home_work, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                basecamp.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
