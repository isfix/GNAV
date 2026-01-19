import 'dart:math' as math;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../data/local/db/app_database.dart';
import 'package:vector_math/vector_math.dart' as vector;

/// A node in the routing graph (typically an intersection or a trail point)
class RoutingNode {
  final String id;
  final double lat;
  final double lng;
  // Edges leading out from this node
  final List<RoutingEdge> edges = [];

  RoutingNode(this.id, this.lat, this.lng);

  LatLng toLatLng() => LatLng(lat, lng);
}

/// A connection between two nodes
class RoutingEdge {
  final RoutingNode toNode;
  final double weight; // Cost (Length * Difficulty)
  final double distance; // Physical distance in meters
  final String trailId; // Which trail this segment belongs to

  RoutingEdge({
    required this.toNode,
    required this.weight,
    required this.distance,
    required this.trailId,
  });
}

class TopologyBuilder {
  // Precision for spatial hashing (5 decimals ~= 1.1m)
  static const int _precision = 5;

  /// Builds a graph from a list of Trails
  static Map<String, RoutingNode> buildGraph(List<Trail> trails) {
    final Map<String, RoutingNode> nodes = {};

    for (final trail in trails) {
      if (trail.geometryJson.isEmpty) continue;

      RoutingNode? prevNode;
      // Difficulty multiplier: Harder trails cost more to traverse
      // 1=Flat, 5=Scramble. Cost = Dist * (1 + (diff-1)*0.2)
      // e.g. Diff 1 => x1.0, Diff 5 => x1.8
      final difficultyMultiplier = 1.0 + ((trail.difficulty - 1) * 0.2);

      for (int i = 0; i < trail.geometryJson.length; i++) {
        final point = trail.geometryJson[i];
        final id = _generateNodeId(point.lat, point.lng);

        // Get or Create Node
        RoutingNode currentNode =
            nodes.putIfAbsent(id, () => RoutingNode(id, point.lat, point.lng));

        // Create Edge if there was a previous point
        if (prevNode != null) {
          final dist = calculateDistance(prevNode, currentNode);
          final weight = dist * difficultyMultiplier;

          // Add Edge: Prev -> Current
          prevNode.edges.add(RoutingEdge(
            toNode: currentNode,
            weight: weight,
            distance: dist,
            trailId: trail.id,
          ));

          // Add Edge: Current -> Prev (Undirected graph for hiking)
          currentNode.edges.add(RoutingEdge(
            toNode: prevNode,
            weight: weight,
            distance: dist,
            trailId: trail.id,
          ));
        }

        prevNode = currentNode;
      }
    }
    return nodes;
  }

  /// Hashes coordinates to a string key for clustering nearby points
  static String _generateNodeId(double lat, double lng) {
    final latStr = lat.toStringAsFixed(_precision);
    final lngStr = lng.toStringAsFixed(_precision);
    return '${latStr}_$lngStr';
  }

  /// Euclidean distance (approximated for small distances) in meters
  static double calculateDistance(RoutingNode a, RoutingNode b) {
    const double earthRadius = 6371000; // meters
    final dLat = vector.radians(b.lat - a.lat);
    final dLng = vector.radians(b.lng - a.lng);
    final a1 = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(vector.radians(a.lat)) *
            math.cos(vector.radians(b.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }
}
