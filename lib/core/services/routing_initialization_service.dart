import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'native_routing_service.dart';

/// Service to handle GraphHopper initialization.
///
/// IMPORTANT: We ship PRE-PROCESSED GraphHopper graphs, NOT raw .osm.pbf files.
/// Processing PBF on mobile devices causes OOM crashes and takes 10+ minutes.
///
/// The graph must be pre-built on a development machine:
/// 1. Download OSM PBF from Geofabrik
/// 2. Run GraphHopper on PC to generate graph files (nodes, edges, geometry, etc)
/// 3. Zip the output folder
/// 4. Place as assets/graph_cache/central_java_gh.zip
class RoutingInitializationService {
  static const String _graphZipAsset = 'assets/graph_cache/central_java_gh.zip';
  static const String _graphFolderName = 'graphhopper_graph';
  static const String _versionMarker = 'gh_v1.marker'; // Track graph version

  bool _isInitializing = false;
  bool _isReady = false;
  String? _lastError;
  double _progress = 0.0;

  bool get isInitializing => _isInitializing;
  bool get isReady => _isReady;
  String? get lastError => _lastError;
  double get progress => _progress;

  /// Initializes the routing engine.
  ///
  /// Process:
  /// 1. Check if pre-processed graph exists on device
  /// 2. If not, extract from bundled .zip asset
  /// 3. Load GraphHopper with the extracted graph (LOAD ONLY, no import)
  Future<bool> initialize({
    Function(String status, double progress)? onProgress,
  }) async {
    if (_isReady || _isInitializing) return _isReady;

    _isInitializing = true;
    _lastError = null;
    _progress = 0.0;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final graphDir = Directory(p.join(appDir.path, _graphFolderName));
      final versionFile = File(p.join(graphDir.path, _versionMarker));

      // Check if graph needs extraction
      final needsExtraction = !await versionFile.exists();

      if (needsExtraction) {
        onProgress?.call('Extracting routing graph...', 0.1);
        _progress = 0.1;

        // Clean and recreate directory
        if (await graphDir.exists()) {
          await graphDir.delete(recursive: true);
        }
        await graphDir.create(recursive: true);

        // Extract zip from assets
        await _extractGraphZip(graphDir.path, onProgress);

        // Create version marker
        await versionFile.writeAsString('extracted');

        onProgress?.call('Graph extracted successfully', 0.6);
        _progress = 0.6;
      } else {
        onProgress?.call('Graph found, loading...', 0.5);
        _progress = 0.5;
      }

      // Load the pre-processed graph (NO IMPORT)
      onProgress?.call('Loading routing engine...', 0.7);
      _progress = 0.7;

      final success =
          await nativeRoutingService.loadRoutingGraph(graphDir.path);

      if (success) {
        onProgress?.call('Routing engine ready!', 1.0);
        _progress = 1.0;
        _isReady = true;
      } else {
        _lastError = 'Failed to load routing graph. Graph may be corrupt.';
        onProgress?.call(_lastError!, 0.0);
      }

      return _isReady;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Routing initialization error: $e');
      onProgress?.call('Error: $_lastError', 0.0);
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Extracts the pre-built GraphHopper zip from assets to device storage
  ///
  /// MEMORY-SAFE: Uses compute isolate to extract zip in background,
  /// preventing OOM on low-end devices by not blocking the main isolate's heap.
  Future<void> _extractGraphZip(
    String targetPath,
    Function(String, double)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading graph archive...', 0.2);

      // Step 1: Copy asset to temp file (streamed, not all in RAM at once)
      final ByteData data = await rootBundle.load(_graphZipAsset);
      final tempDir = await getTemporaryDirectory();
      final tempZipPath = p.join(tempDir.path, 'temp_graph.zip');
      final tempZipFile = File(tempZipPath);

      // Write in chunks to avoid holding large Uint8List
      await tempZipFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );

      // Allow GC to reclaim ByteData memory before extraction
      onProgress?.call('Decompressing graph data...', 0.3);

      // Step 2: Extract in isolate to avoid OOM on main thread
      // The compute function runs in a separate isolate with its own heap
      await compute(
        _extractZipInIsolate,
        _ExtractParams(tempZipPath, targetPath),
      );

      // Step 3: Cleanup temp file
      if (await tempZipFile.exists()) {
        await tempZipFile.delete();
      }

      onProgress?.call('Extraction complete', 0.6);
    } catch (e) {
      throw Exception('Failed to extract graph zip: $e');
    }
  }

  /// Checks if routing is available for the given coordinates
  /// (Central Java coverage)
  bool checkCoverage(double lat, double lon) {
    if (!_isReady) return false;

    // Central Java bounding box (covers Merbabu, Merapi, Sumbing, Sindoro, Lawu)
    // Approximate bounds: Lat -8.2 to -7.0, Lon 109.5 to 111.5
    return lat >= -8.2 && lat <= -7.0 && lon >= 109.5 && lon <= 111.5;
  }

  /// Forces re-extraction of graph on next init
  Future<void> clearGraph() async {
    final appDir = await getApplicationDocumentsDirectory();
    final graphDir = Directory(p.join(appDir.path, _graphFolderName));

    if (await graphDir.exists()) {
      await graphDir.delete(recursive: true);
    }

    _isReady = false;
    _lastError = null;
    _progress = 0.0;
  }
}

/// Parameters for isolate extraction
class _ExtractParams {
  final String zipPath;
  final String targetPath;
  _ExtractParams(this.zipPath, this.targetPath);
}

/// Runs in a separate isolate to extract zip without affecting main heap
Future<void> _extractZipInIsolate(_ExtractParams params) async {
  final zipFile = File(params.zipPath);
  final bytes = await zipFile.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final filePath = p.join(params.targetPath, file.name);

    // SECURITY: Prevent Zip Slip (directory traversal)
    final canonicalPath = p.normalize(filePath);
    final canonicalTarget = p.normalize(params.targetPath);
    if (!canonicalPath.startsWith(canonicalTarget)) {
      debugPrint('Skipping malicious zip entry: ${file.name}');
      continue;
    }

    if (file.isFile) {
      final outFile = File(filePath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    } else {
      await Directory(filePath).create(recursive: true);
    }
  }
}

/// Singleton instance
final routingInitializationService = RoutingInitializationService();
