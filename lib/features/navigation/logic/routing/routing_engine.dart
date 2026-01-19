import 'package:collection/collection.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../data/local/db/app_database.dart';
import 'kd_tree.dart';
import 'topology_builder.dart';

class RoutingEngine {
  static const double _kMaxSnapDistance = 1000.0;

  Map<String, RoutingNode> _graph = {};
  KDTree? _kdTree;

  /// Rebuilds the graph from trails. Call this on mountain region change.
  void initializeGraph(List<Trail> trails) {
    _graph = TopologyBuilder.buildGraph(trails);
    _kdTree = KDTree.build(_graph.values.toList());
  }

  /// Finds the shortest path between two points.
  ///
  /// 1. Snaps start/end to nearest nodes in the graph.
  /// 2. Runs A* algorithm.
  /// 3. Returns list of LatLngs representing the path.
  List<LatLng>? findRoute(LatLng start, LatLng end) {
    if (_graph.isEmpty) return null;

    final startNode = _findNearestNode(start);
    final endNode = _findNearestNode(end);

    if (startNode == null || endNode == null) return null;
    if (startNode.id == endNode.id) return [start];

    // A* Algorithm
    // Open Set: Nodes to visit, ordered by fScore (priority)
    final openSet =
        PriorityQueue<_NodeWrapper>((a, b) => a.fScore.compareTo(b.fScore));

    // Cost from start to node
    final gScore = <String, double>{};

    // Predecessor map to reconstruct path
    final cameFrom = <String, RoutingNode>{};

    // Initialize
    gScore[startNode.id] = 0;
    openSet.add(_NodeWrapper(startNode, 0 + _heuristic(startNode, endNode)));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst().node;

      if (current.id == endNode.id) {
        return _reconstructPath(cameFrom, current);
      }

      for (final edge in current.edges) {
        final neighbor = edge.toNode;
        final tentativeGScore = gScore[current.id]! + edge.weight;

        if (tentativeGScore < (gScore[neighbor.id] ?? double.infinity)) {
          cameFrom[neighbor.id] = current;
          gScore[neighbor.id] = tentativeGScore;
          final fScore = tentativeGScore + _heuristic(neighbor, endNode);

          // Note: PriorityQueue doesn't support updateKey, so we just add.
          // visited check ideally handles duplicates, or we accept minor overhead.
          openSet.add(_NodeWrapper(neighbor, fScore));
        }
      }
    }

    return null; // No path found
  }

  RoutingNode? _findNearestNode(LatLng point) {
    final target = RoutingNode('temp', point.latitude, point.longitude);

    if (_kdTree != null) {
      final bestNode = _kdTree!.nearest(target);
      if (bestNode != null) {
        final dist = TopologyBuilder.calculateDistance(bestNode, target);
        // Only snap if within reasonable distance (e.g. 1km)
        if (dist <= _kMaxSnapDistance) return bestNode;
      }
      return null;
    }

    // Fallback if tree not built
    RoutingNode? bestNode;
    double minDist = double.infinity;

    for (final node in _graph.values) {
      final dist = TopologyBuilder.calculateDistance(node, target);
      if (dist < minDist) {
        minDist = dist;
        bestNode = node;
      }
    }
    // Only snap if within reasonable distance (e.g. 1km)
    if (minDist > _kMaxSnapDistance) return null;

    return bestNode;
  }

  double _heuristic(RoutingNode a, RoutingNode b) {
    return TopologyBuilder.calculateDistance(a, b);
  }

  List<LatLng> _reconstructPath(
      Map<String, RoutingNode> cameFrom, RoutingNode current) {
    final totalPath = <LatLng>[current.toLatLng()];
    while (cameFrom.containsKey(current.id)) {
      current = cameFrom[current.id]!;
      totalPath.add(current.toLatLng());
    }
    return totalPath.reversed.toList();
  }
}

class _NodeWrapper {
  final RoutingNode node;
  final double fScore;
  _NodeWrapper(this.node, this.fScore);
}
