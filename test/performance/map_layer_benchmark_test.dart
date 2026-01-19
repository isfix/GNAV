import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/core/services/map_layer_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

class MockMapLibreMapController extends Fake implements MapLibreMapController {
  int addSymbolCallCount = 0;
  int clearSymbolsCallCount = 0;
  int addGeoJsonSourceCallCount = 0;
  int setGeoJsonSourceCallCount = 0;
  int addSymbolLayerCallCount = 0;
  int removeLayerCallCount = 0;
  int removeSourceCallCount = 0;

  @override
  Future<void> clearSymbols() async {
    clearSymbolsCallCount++;
  }

  @override
  Future<Symbol> addSymbol(SymbolOptions options, [Map? data]) async {
    addSymbolCallCount++;
    return Symbol('id_$addSymbolCallCount', options);
  }

  @override
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson, {String? promoteId}) async {
    addGeoJsonSourceCallCount++;
  }

  @override
  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson) async {
    setGeoJsonSourceCallCount++;
  }

  @override
  Future<void> addSymbolLayer(String sourceId, String layerId, SymbolLayerProperties properties, {String? belowLayerId, String? sourceLayer, double? minzoom, double? maxzoom, dynamic filter, bool enableInteraction = true}) async {
    addSymbolLayerCallCount++;
  }

  @override
  Future<void> removeLayer(String layerId) async {
    removeLayerCallCount++;
  }

  @override
  Future<void> removeSource(String sourceId) async {
    removeSourceCallCount++;
  }
}

void main() {
  test('MapLayerService.addPOIMarkers benchmark', () async {
    final service = MapLayerService();
    final controller = MockMapLibreMapController();
    service.attach(controller);

    final pois = List.generate(1000, (index) => PointOfInterest(
      id: 'poi_$index',
      mountainId: 'mt_1',
      name: 'POI $index',
      type: PoiType.water,
      lat: -7.0 + (index * 0.0001),
      lng: 110.0 + (index * 0.0001),
    ));

    final stopwatch = Stopwatch()..start();
    await service.addPOIMarkers(pois);
    stopwatch.stop();

    print('Execution time: ${stopwatch.elapsedMilliseconds}ms');
    print('addSymbol calls: ${controller.addSymbolCallCount}');
    print('addGeoJsonSource calls: ${controller.addGeoJsonSourceCallCount}');
    print('addSymbolLayer calls: ${controller.addSymbolLayerCallCount}');

    // Expecting optimization: 0 addSymbol calls, 1 addGeoJsonSource call, 1 addSymbolLayer call
    expect(controller.addSymbolCallCount, 0, reason: 'Should NOT call addSymbol individually');
    expect(controller.addGeoJsonSourceCallCount, 1, reason: 'Should use GeoJsonSource');
    expect(controller.addSymbolLayerCallCount, 1, reason: 'Should use SymbolLayer');
  });
}
