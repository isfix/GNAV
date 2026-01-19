import 'topology_builder.dart';

class KDNode {
  final RoutingNode node;
  final KDNode? left;
  final KDNode? right;

  KDNode(this.node, {this.left, this.right});
}

class KDTree {
  final KDNode? root;

  KDTree._(this.root);

  /// Builds a KD-Tree from a list of RoutingNodes.
  /// The list is modified (sorted) during construction.
  static KDTree build(List<RoutingNode> nodes) {
    if (nodes.isEmpty) return KDTree._(null);
    // Clone list to avoid modifying original if needed, but here we can just use it.
    // However, usually it's safer to copy if the caller expects the list order preserved.
    // We'll copy.
    return KDTree._(_buildRecursive(List.of(nodes), 0));
  }

  static KDNode? _buildRecursive(List<RoutingNode> nodes, int depth) {
    if (nodes.isEmpty) return null;

    final axis = depth % 2; // 0 for lat, 1 for lng

    // Sort nodes based on current axis
    nodes.sort((a, b) {
      if (axis == 0) return a.lat.compareTo(b.lat);
      return a.lng.compareTo(b.lng);
    });

    final medianIndex = nodes.length ~/ 2;
    final medianNode = nodes[medianIndex];

    return KDNode(
      medianNode,
      left: _buildRecursive(nodes.sublist(0, medianIndex), depth + 1),
      right: _buildRecursive(nodes.sublist(medianIndex + 1), depth + 1),
    );
  }

  /// Finds the nearest node to the target.
  RoutingNode? nearest(RoutingNode target) {
    if (root == null) return null;

    KDNode? bestNode;
    double bestDist = double.infinity;

    void search(KDNode? node, int depth) {
      if (node == null) return;

      final dist = TopologyBuilder.calculateDistance(target, node.node);
      if (dist < bestDist) {
        bestDist = dist;
        bestNode = node;
      }

      final axis = depth % 2;
      final diff = (axis == 0) ? target.lat - node.node.lat : target.lng - node.node.lng;

      final near = diff < 0 ? node.left : node.right;
      final far = diff < 0 ? node.right : node.left;

      search(near, depth + 1);

      // Pruning check
      double planeDist;
      if (axis == 0) {
         // Split on Lat. Plane is Line(lat = node.lat)
         // Shortest distance is to (node.lat, target.lng)
         final projection = RoutingNode('temp_plane', node.node.lat, target.lng);
         planeDist = TopologyBuilder.calculateDistance(target, projection);
      } else {
         // Split on Lng. Plane is Line(lng = node.lng)
         // Shortest distance is to (target.lat, node.lng)
         final projection = RoutingNode('temp_plane', target.lat, node.node.lng);
         planeDist = TopologyBuilder.calculateDistance(target, projection);
      }

      if (planeDist < bestDist) {
        search(far, depth + 1);
      }
    }

    search(root, 0);
    return bestNode?.node;
  }
import 'dart:math' as math;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'topology_builder.dart';

class KdTree {
  _KdNode? _root;

  void build(List<RoutingNode> nodes) {
    if (nodes.isEmpty) {
      _root = null;
      return;
    }
    // Create wrappers with 3D coordinates
    final points = nodes.map((n) => _KdPoint(n)).toList();
    _root = _buildTree(points, 0);
  }

  _KdNode? _buildTree(List<_KdPoint> points, int depth) {
    if (points.isEmpty) return null;

    final axis = depth % 3; // 3D: x, y, z

    // Sort by current axis
    points.sort((a, b) => a.vec[axis].compareTo(b.vec[axis]));

    final medianIndex = points.length ~/ 2;
    final medianNode = points[medianIndex];

    return _KdNode(
      point: medianNode,
      left: _buildTree(points.sublist(0, medianIndex), depth + 1),
      right: _buildTree(points.sublist(medianIndex + 1), depth + 1),
      axis: axis,
    );
  }

  RoutingNode? findNearest(LatLng target) {
    if (_root == null) return null;

    final targetVec = _latLngToVector(target.latitude, target.longitude);

    // Initial best is the root
    _KdPoint best = _root!.point;
    double bestDistSq = _distSq(targetVec, best.vec);

    void search(_KdNode? node) {
      if (node == null) return;

      final distSq = _distSq(targetVec, node.point.vec);
      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        best = node.point;
      }

      final axis = node.axis;
      final diff = targetVec[axis] - node.point.vec[axis];

      // Determine which side to search first
      final near = diff < 0 ? node.left : node.right;
      final far = diff < 0 ? node.right : node.left;

      search(near);

      // Check if we need to search the other side
      if (diff * diff < bestDistSq) {
        search(far);
      }
    }

    search(_root);
    return best.node;
  }

  static _Vector3 _latLngToVector(double lat, double lng) {
    // Convert lat/lng to unit sphere 3D coordinates
    final rLat = lat * (math.pi / 180.0);
    final rLng = lng * (math.pi / 180.0);

    final x = math.cos(rLat) * math.cos(rLng);
    final y = math.cos(rLat) * math.sin(rLng);
    final z = math.sin(rLat);

    return _Vector3(x, y, z);
  }

  static double _distSq(_Vector3 a, _Vector3 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return dx*dx + dy*dy + dz*dz;
  }
}

class _Vector3 {
  final double x, y, z;
  _Vector3(this.x, this.y, this.z);

  double operator [](int index) {
    if (index == 0) return x;
    if (index == 1) return y;
    if (index == 2) return z;
    throw RangeError(index);
  }
}

class _KdPoint {
  final RoutingNode node;
  final _Vector3 vec;

  _KdPoint(this.node) : vec = KdTree._latLngToVector(node.lat, node.lng);
}

class _KdNode {
  final _KdPoint point;
  final _KdNode? left;
  final _KdNode? right;
  final int axis;

  _KdNode({
    required this.point,
    this.left,
    this.right,
    required this.axis,
  });
}
