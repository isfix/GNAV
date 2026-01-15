import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../logic/navigation_providers.dart';

class SearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(dynamic) onSelect;

  const SearchOverlay(
      {super.key, required this.onClose, required this.onSelect});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = "";

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Data
    final allMountains = ref.watch(allMountainsProvider).valueOrNull ?? [];

    // 2. Filter
    final results = _query.isEmpty
        ? allMountains
        : allMountains
            .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: const Color(0xFF050505).withOpacity(0.95),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: const Color(0xFF141414).withOpacity(1.0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    const Color(0xFF0df259).withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF0df259).withOpacity(0.15),
                                  blurRadius: 15)
                            ]),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF0df259)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search active peaks...",
                                  hintStyle: TextStyle(color: Colors.white30)),
                              onChanged: (val) => setState(() => _query = val),
                            )),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  setState(() => _query = "");
                                },
                                child: const Icon(Icons.cancel,
                                    color: Colors.white30, size: 20),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                        onPressed: widget.onClose,
                        child: const Text("Cancel",
                            style: TextStyle(
                                color: Color(0xFF0df259),
                                fontWeight: FontWeight.bold)))
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION TITLE
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text("SEARCH RESULTS (${results.length})",
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ),

              // RESULTS LIST
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final region = results[index];
                    return GestureDetector(
                      onTap: () => widget.onSelect(region),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF141414).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: const BorderSide(
                                  color: Color(0xFF0df259), width: 4),
                              top: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                              bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                              right: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                            )),
                        child: Row(
                          children: [
                            // ICON
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(Icons.filter_hdr,
                                  color: Color(0xFF0df259), size: 20),
                            ),
                            const SizedBox(width: 16),
                            // TEXT
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(region.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _Tag(text: region.id.toUpperCase()),
                                    const SizedBox(width: 8),
                                    if (region.isDownloaded)
                                      const _Tag(
                                          text: "OFFLINE",
                                          color: Color(0xFF0df259)),
                                  ],
                                )
                              ],
                            )),
                            // ARROW
                            const Icon(Icons.chevron_right,
                                color: Colors.white24)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // FOOTER
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.offline_pin,
                        color: Colors.white24, size: 16),
                    const SizedBox(width: 8),
                    Text("AVAILABLE OFFLINE",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, this.color = const Color(0xFFFFFFFF)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.bold)),
    );
  }
}
