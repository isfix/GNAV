import 'dart:typed_data';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:mbtiles/mbtiles.dart';

class MbTilesVectorTileProvider extends VectorTileProvider {
  final String path;
  MbTiles? _mbtiles;

  MbTilesVectorTileProvider({required this.path});

  Future<void> _init() async {
    _mbtiles ??= MbTiles(mbtilesPath: path);
  }

  @override
  int get maximumZoom => 16;
  // TODO: Read metadata from mbtiles if possible, but 16 is safe for most hiking maps.

  @override
  int get minimumZoom => 8;

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    await _init();

    // In TMS (MBTiles) y is flipped relative to Google/OSM (XYZ)
    // Formula: y = (2^z) - 1 - y
    final z = tile.z;
    final x = tile.x;
    final y = (1 << z) - 1 - tile.y;

    final data = _mbtiles!.getTile(z: z, x: x, y: y);
    if (data == null) {
      throw Exception('Tile not found: $z/$x/$y');
    }
    return Uint8List.fromList(data);
  }
}
