import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/core/services/map_layer_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

// Mock Controller
class MockMapLibreMapController extends Fake implements MapLibreMapController {
  final Map<String, int> addImageCalls = {};

  @override
  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]) async {
    addImageCalls.update(name, (value) => value + 1, ifAbsent: () => 1);
  }

  @override
  Future<void> clearSymbols() async {}

  @override
  Future<void> removeLayer(String layerId) async {}

  @override
  Future<void> removeSource(String sourceId) async {}

  @override
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson, {String? promoteId}) async {}

  @override
  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson) async {}

  @override
  Future<void> addSymbolLayer(String sourceId, String layerId, SymbolLayerProperties properties, {String? belowLayerId, String? sourceLayer, double? minzoom, double? maxzoom, dynamic filter, bool enableInteraction = true}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MapLayerService service;
  late MockMapLibreMapController mockController;

  setUp(() {
    service = MapLayerService();
    mockController = MockMapLibreMapController();

    // Mock rootBundle for all icons
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        return ByteData(10);
      },
    );
  });

  test('addPOIMarkers loads all icons concurrently and only once', () async {
    service.attach(mockController);

    // Create a dummy POI
    final poi = PointOfInterest(
      id: '1',
      name: 'Test POI',
      type: PoiType.campsite,
      lat: 0.0,
      lng: 0.0,
      mountainId: 'm1',
      elevation: 1000.0,
      metadataJson: null,
    );

    // --- First call ---
    await service.addPOIMarkers([poi]);

    // Verify ALL icons were loaded exactly once
    final expectedIcons = [
      'icon_basecamp',
      'icon_water',
      'icon_shelter',
      'icon_dangerZone',
      'icon_summit',
      'icon_viewpoint',
      'icon_campsite',
      'icon_junction',
      'icon_default',
    ];

    for (final icon in expectedIcons) {
      expect(mockController.addImageCalls[icon], 1,
          reason: '$icon should be loaded once on the first call.');
    }
    expect(mockController.addImageCalls.length, expectedIcons.length,
        reason: 'Only the expected icons should be loaded.');

    // --- Second call ---
    await service.addPOIMarkers([poi]);

    // Verify icons were NOT loaded again
    for (final icon in expectedIcons) {
      expect(mockController.addImageCalls[icon], 1,
          reason: '$icon should NOT be reloaded on the second call.');
    }
    expect(mockController.addImageCalls.length, expectedIcons.length,
        reason: 'No new icons should have been loaded on the second call.');
  });
}
