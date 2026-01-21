import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Domain Models ---

class TrackConfig {
  final String name;
  final String path;

  TrackConfig({required this.name, required this.path});

  factory TrackConfig.fromJson(Map<String, dynamic> json) {
    return TrackConfig(
      name: json['name'] as String,
      path: json['file'] as String,
    );
  }
}

class MountainConfig {
  final String id;
  final String name;
  final String region;
  final List<TrackConfig> tracks;
  final String poiFile;
  final String mbtilesPath;
  final String difficulty;
  final String description;
  final bool isActive;

  MountainConfig({
    required this.id,
    required this.name,
    required this.region,
    required this.tracks,
    required this.poiFile,
    required this.mbtilesPath,
    required this.difficulty,
    required this.description,
    required this.isActive,
  });

  factory MountainConfig.fromJson(Map<String, dynamic> json) {
    var tracksList = json['tracks'] as List? ?? [];
    List<TrackConfig> tracks =
        tracksList.map((i) => TrackConfig.fromJson(i)).toList();

    return MountainConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String? ?? 'Unknown',
      tracks: tracks,
      poiFile: json['poi_file'] as String? ?? '',
      mbtilesPath: json['mbtiles_path'] as String,
      difficulty: json['difficulty'] as String,
      description: json['description'] as String? ?? '',
      isActive: json['active'] as bool? ?? true,
    );
  }
}

class AppConfig {
  final int version;
  final List<MountainConfig> mountains;

  AppConfig({required this.version, required this.mountains});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    var list = json['mountains'] as List;
    List<MountainConfig> mountainsList =
        list.map((i) => MountainConfig.fromJson(i)).toList();

    return AppConfig(
      version: json['version'] as int,
      mountains: mountainsList,
    );
  }
}

// --- Service ---

class ConfigService {
  AppConfig? _config;

  Future<void> loadConfig() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/mountains.json');
      final jsonMap = json.decode(jsonString);
      _config = AppConfig.fromJson(jsonMap);
    } catch (e) {
      // Fallback or rethrow? For now log error.
      // In a real app we might want a default config or retry mechanism.
      print('Error loading mountains.json: $e');
      rethrow;
    }
  }

  List<MountainConfig> get mountains => _config?.mountains ?? [];

  MountainConfig? getMountain(String id) {
    try {
      return _config?.mountains.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

// --- Providers ---

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

final mountainsProvider = FutureProvider<List<MountainConfig>>((ref) async {
  final service = ref.watch(configServiceProvider);
  await service.loadConfig();
  return service.mountains;
});
