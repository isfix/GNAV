import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/services/map_layer_service.dart';
import '../../../core/utils/offline_map_style_helper.dart';
import '../../navigation/logic/navigation_providers.dart';
import '../widgets/action_buttons.dart';
import '../widgets/draggable_bottom_sheet.dart';
import '../widgets/header_display.dart';
import '../widgets/off_trail_warning.dart';
import '../widgets/status_bar.dart';

class HomeScreenV2 extends ConsumerStatefulWidget {
  const HomeScreenV2({super.key});

  @override
  ConsumerState<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends ConsumerState<HomeScreenV2> {
  MapLibreMapController? _mapController;
  late final MapLayerService mapLayerService;
  String? _styleString;

  @override
  void initState() {
    super.initState();
    mapLayerService = MapLayerService();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    // For now, let's use the default online style.
    // In the future, this can be extended to use offline maps.
    final style =
        await OfflineMapStyleHelper.getOfflineStyle('assets/map_styles/mapstyle.json');
    if (mounted) {
      setState(() {
        _styleString = style;
      });
    }
  }

  Future<void> _drawMapLayers() async {
    final activeMountainId = ref.read(activeMountainIdProvider);
    final trails = await ref.read(activeTrailsProvider(activeMountainId).future);
    await mapLayerService.drawTrails(trails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_styleString == null)
            const Center(child: CircularProgressIndicator())
          else
            MapLibreMap(
              styleString: _styleString!,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-7.453, 110.448), // Mt. Merbabu
                zoom: 12.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                mapLayerService.attach(controller);
              },
              onStyleLoadedCallback: _drawMapLayers,
            ),
          const StatusBar(),
          const HeaderDisplay(),
          const ActionButtons(),
          const OffTrailWarning(),
          const DraggableBottomSheet(),
        ],
      ),
    );
  }
}
