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
}
