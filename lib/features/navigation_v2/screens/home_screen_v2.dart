import 'package:flutter/material.dart';
import '../widgets/action_buttons.dart';
import '../widgets/draggable_bottom_sheet.dart';
import '../widgets/header_display.dart';
import '../widgets/off_trail_warning.dart';
import '../widgets/status_bar.dart';

class HomeScreenV2 extends StatelessWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          // TODO: Add Map View
          Placeholder(), // Placeholder for the map
          StatusBar(),
          HeaderDisplay(),
          ActionButtons(),
          OffTrailWarning(),
          DraggableBottomSheet(),
        ],
      ),
    );
  }
}
