import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/features/navigation/logic/routing/kd_tree.dart';
import 'package:pandu_navigation/features/navigation/logic/routing/topology_builder.dart';

void main() {
  group('KdTree', () {
    test('findNearest returns null when tree is empty', () {
      final tree = KdTree();
      tree.build([]);
      expect(tree.findNearest(const LatLng(0, 0)), isNull);
    });

    test('findNearest returns the only node for single-node tree', () {
      final node = RoutingNode('1', 0, 0);
      final tree = KdTree();
      tree.build([node]);
      final nearest = tree.findNearest(const LatLng(0.0001, 0.0001));
      expect(nearest, equals(node));
    });

    test('findNearest returns correct nearest node among multiple nodes', () {
      final nodeA = RoutingNode('A', 10.0, 10.0);
      final nodeB = RoutingNode('B', 10.0, 11.0);
      final nodeC = RoutingNode('C', 11.0, 10.0);
      final tree = KdTree();
      tree.build([nodeA, nodeB, nodeC]);

      // Near A
      expect(tree.findNearest(const LatLng(10.01, 10.01)), equals(nodeA));
      // Near B
      expect(tree.findNearest(const LatLng(10.01, 10.99)), equals(nodeB));
      // Near C
      expect(tree.findNearest(const LatLng(10.99, 10.01)), equals(nodeC));
    });

    test('findNearest works near dateline', () {
      final nodeWest = RoutingNode('W', 0, -179.0);
      final nodeEast = RoutingNode('E', 0, 179.0);
      final nodeZero = RoutingNode('Z', 0, 0);

      final tree = KdTree();
      tree.build([nodeWest, nodeEast, nodeZero]);

      // Target at 179.9 should be close to E (179.0) -> dist 0.9 deg
      // Z (0) is 179.9 deg away.
      // W (-179) is 2 deg away (across 180).
      expect(tree.findNearest(const LatLng(0, 179.9)), equals(nodeEast));

      // Target at -179.9 should be close to W (-179.0) -> dist 0.9 deg
      expect(tree.findNearest(const LatLng(0, -179.9)), equals(nodeWest));
    });
  });
}
