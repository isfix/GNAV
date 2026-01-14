import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/seeding_service.dart';

class RegionListScreen extends ConsumerStatefulWidget {
  const RegionListScreen({super.key});

  @override
  ConsumerState<RegionListScreen> createState() => _RegionListScreenState();
}

class _RegionListScreenState extends ConsumerState<RegionListScreen> {
  bool _isLoading = false;
  String? _loadingId;

  Future<void> _downloadRegion(String id) async {
    setState(() {
      _isLoading = true;
      _loadingId = id;
    });

    // Simulate Network/Download delay
    await Future.delayed(const Duration(seconds: 2));

    // Seed Data
    // The original code used `SeedingService(db)`, but the instruction implies
    // a switch to `seedingServiceProvider`. Assuming `seedingServiceProvider`
    // is defined elsewhere and provides an instance of `SeedingService`.
    switch (id) {
      case 'merbabu':
        await ref.read(seedingServiceProvider).seedMerbabu();
        break;
      case 'rinjani':
        await ref.read(seedingServiceProvider).seedRinjani();
        break;
      case 'semeru':
        await ref.read(seedingServiceProvider).seedSemeru();
        break;
      case 'slamet':
        await ref.read(seedingServiceProvider).seedSlamet();
        break;
      case 'sumbing':
        await ref.read(seedingServiceProvider).seedSumbing();
        break;
      case 'arjuno':
        await ref.read(seedingServiceProvider).seedArjuno();
        break;
      case 'raung':
        await ref.read(seedingServiceProvider).seedRaung();
        break;
      case 'lawu':
        await ref.read(seedingServiceProvider).seedLawu();
        break;
      case 'welirang':
        await ref.read(seedingServiceProvider).seedWelirang();
        break;
      case 'sindoro':
        await ref.read(seedingServiceProvider).seedSindoro();
        break;
      case 'argopuro':
        await ref.read(seedingServiceProvider).seedArgopuro();
        break;
      case 'ciremai':
        await ref.read(seedingServiceProvider).seedCiremai();
        break;
      case 'pangrango':
        await ref.read(seedingServiceProvider).seedPangrango();
        break;
      case 'gede':
        await ref.read(seedingServiceProvider).seedGede();
        break;
      case 'merapi':
        await ref.read(seedingServiceProvider).seedMerapi();
        break;
      case 'butak':
        await ref.read(seedingServiceProvider).seedButak();
        break;
      case 'kerinci':
      default:
        await ref.read(seedingServiceProvider).seedKerinci();
        break;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingId = null;
      });
      context.go('/'); // Go to Map
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Expeditions'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[900]!, Colors.black],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.terrain, size: 100, color: Colors.white10),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroRegionCard(
                  id: 'merbabu',
                  name: 'Mount Merbabu',
                  elevation: '3,145m',
                  difficulty: 'Medium',
                  location: 'Central Java',
                  color: Colors.green,
                  isLoading: _isLoading && _loadingId == 'merbabu',
                  onTap: () => _downloadRegion('merbabu'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'slamet',
                  name: 'Mount Slamet',
                  elevation: '3,432 mdpl',
                  difficulty: 'Hard',
                  location: 'Central Java',
                  color: Colors.blue,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'slamet',
                  onTap: () => _downloadRegion('slamet'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'sumbing',
                  name: 'Mount Sumbing',
                  elevation: '3,371 mdpl',
                  difficulty: 'Hard',
                  location: 'Central Java',
                  color: Colors.indigo,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'sumbing',
                  onTap: () => _downloadRegion('sumbing'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'arjuno',
                  name: 'Mount Arjuno',
                  elevation: '3,339 mdpl',
                  difficulty: 'Hard',
                  location: 'East Java',
                  color: Colors.teal,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'arjuno',
                  onTap: () => _downloadRegion('arjuno'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'raung',
                  name: 'Mount Raung',
                  elevation: '3,344 mdpl',
                  difficulty: 'Extreme',
                  location: 'East Java',
                  color: Colors.redAccent,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'raung',
                  onTap: () => _downloadRegion('raung'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'lawu',
                  name: 'Mount Lawu',
                  elevation: '3,265 mdpl',
                  difficulty: 'Medium',
                  location: 'Border Central/East Java',
                  color: Colors.brown,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'lawu',
                  onTap: () => _downloadRegion('lawu'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'welirang',
                  name: 'Mount Welirang',
                  elevation: '3,156 mdpl',
                  difficulty: 'Hard',
                  location: 'East Java',
                  color: Colors.yellow[800]!,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'welirang',
                  onTap: () => _downloadRegion('welirang'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'sindoro',
                  name: 'Mount Sindoro',
                  elevation: '3,153 mdpl',
                  difficulty: 'Medium',
                  location: 'Central Java',
                  color: Colors.indigoAccent,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'sindoro',
                  onTap: () => _downloadRegion('sindoro'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'argopuro',
                  name: 'Mount Argopuro',
                  elevation: '3,088 mdpl',
                  difficulty: 'Very Hard', // Long track
                  location: 'East Java',
                  color: Colors.greenAccent,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'argopuro',
                  onTap: () => _downloadRegion('argopuro'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'ciremai',
                  name: 'Mount Ciremai',
                  elevation: '3,078 mdpl',
                  difficulty: 'Hard',
                  location: 'West Java',
                  color: Colors.deepPurple,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'ciremai',
                  onTap: () => _downloadRegion('ciremai'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'pangrango',
                  name: 'Mount Pangrango',
                  elevation: '3,019 mdpl',
                  difficulty: 'Hard',
                  location: 'West Java',
                  color: Colors.cyan,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'pangrango',
                  onTap: () => _downloadRegion('pangrango'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'gede',
                  name: 'Mount Gede',
                  elevation: '2,958 mdpl',
                  difficulty: 'Medium',
                  location: 'West Java',
                  color: Colors.lightGreen,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'gede',
                  onTap: () => _downloadRegion('gede'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'merapi',
                  name: 'Mount Merapi',
                  elevation: '2,930 mdpl',
                  difficulty: 'HIGH RISK', // Updated difficulty
                  location: 'Central Java',
                  color: Colors.red,
                  isEnabled: false, // Disabled
                  statusText: 'CLOSED - DANGER ZONE', // Explicit Flag
                  isLoading: _isLoading && _loadingId == 'merapi',
                  onTap: () => {}, // No-op
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'butak',
                  name: 'Mount Butak',
                  elevation: '2,868 mdpl',
                  difficulty: 'Medium',
                  location: 'East Java',
                  color: Colors.lime,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'butak',
                  onTap: () => _downloadRegion('butak'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'rinjani',
                  name: 'Mount Rinjani',
                  elevation: '3,726m',
                  difficulty: 'Hard',
                  location: 'Lombok',
                  color: Colors.orange,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'rinjani',
                  onTap: () => _downloadRegion('rinjani'),
                ),
                const SizedBox(height: 20),
                _HeroRegionCard(
                  id: 'semeru',
                  name: 'Mount Semeru',
                  elevation: '3,676m',
                  difficulty: 'Extreme',
                  location: 'East Java',
                  color: Colors.red,
                  isEnabled: true,
                  isLoading: _isLoading && _loadingId == 'semeru',
                  onTap: () => _downloadRegion('semeru'),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}

class _HeroRegionCard extends StatelessWidget {
  final String id;
  final String name;
  final String elevation;
  final String difficulty;
  final String location;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading;
  final String? statusText; // New parameter

  const _HeroRegionCard({
    required this.id,
    required this.name,
    required this.elevation,
    required this.difficulty,
    required this.location,
    required this.color,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.3)
                : Colors.red
                    .withValues(alpha: 0.3), // Red border if disabled/danger
            width: 1,
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isEnabled
                            ? color.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            location.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (!isEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: statusText?.contains('DANGER') == true
                                    ? Colors.red[900]
                                    : Colors.grey[800],
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(statusText ?? 'COMING SOON',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    const Spacer(),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.white : Colors.grey[600],
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.terrain,
                            size: 16,
                            color:
                                isEnabled ? Colors.white70 : Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          elevation,
                          style: TextStyle(
                              color: isEnabled
                                  ? Colors.white70
                                  : Colors.grey[700]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.speed,
                            size: 16,
                            color: isEnabled ? color : Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: TextStyle(
                              color: isEnabled ? color : Colors.grey[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // 3. Download/Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (isEnabled && !isLoading)
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.download, color: Colors.black),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
