import 'package:flutter/material.dart';
import 'glass_panel.dart';
import '../../../core/theme/tactical_theme.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 100,
      right: 16,
      child: Column(
        children: [
          _buildActionButton(icon: Icons.add),
          const SizedBox(height: 12),
          _buildActionButton(icon: Icons.remove),
          const SizedBox(height: 24),
          _buildActionButton(icon: Icons.near_me, color: TacticalTheme.primary),
          const SizedBox(height: 12),
          _buildActionButton(icon: Icons.layers),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, Color? color}) {
    return GlassPanel(
      child: Icon(
        icon,
        color: color ?? Colors.white,
        size: 24,
      ),
    );
  }
}
