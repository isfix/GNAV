import 'package:flutter/material.dart';
import 'dart:ui';

class MapSearchBar extends StatelessWidget {
  final Function(String)? onSearch;
  final bool enabled;

  const MapSearchBar({super.key, this.enabled = true, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414).withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: enabled
                    ? TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search mountain...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: onSearch,
                      )
                    : const Text("Search mountain...",
                        style: TextStyle(color: Colors.grey)),
              ),
              if (!enabled)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Tap to Search",
                        style: TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)))
            ],
          ),
        ),
      ),
    );
  }
}
