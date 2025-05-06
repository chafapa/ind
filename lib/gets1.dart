import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'preferences.dart';
import 'home.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RestaurantSelectionScreen extends StatefulWidget {
  const RestaurantSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantSelectionScreen> createState() =>
      _RestaurantSelectionScreenState();
}

class _RestaurantSelectionScreenState extends State<RestaurantSelectionScreen> {
  final List<Map<String, dynamic>> _allRestaurants = [
    {
      'name': 'Bistro 22',
      'image': 'assets/bistro.jpg',
      'users': '100 U',
      'color': const Color(0xFF5731EA),
    },
    {
      'name': 'Café Mondo',
      'image': 'assets/cafe.jpg',
      'users': '160 U',
      'color': const Color(0xFF5731EA),
    },
    {
      'name': 'Living Room',
      'image': 'assets/livingroom.jpg',
      'users': '92 U',
      'color': const Color(0xFF5731EA),
    },
    {
      'name': 'KFC',
      'image': 'assets/kfc.jpg',
      'users': '92 U',
      'color': const Color(0xFF5731EA),
    },
    {
      'name': 'Treehouse Restaurant',
      'image': 'assets/treehouse.jpg',
      'users': '150 U',
      'color': const Color(0xFF5731EA),
    },
    {
      'name': 'Papaye',
      'image': 'assets/papaye.png',
      'users': '92 U',
      'color': const Color(0xFF5731EA),
    },
  ];

  List<Map<String, dynamic>> _filteredRestaurants = [];
  final List<Map<String, dynamic>> _selected = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = List.from(_allRestaurants);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredRestaurants = List.from(_allRestaurants);
      } else {
        _filteredRestaurants =
            _allRestaurants
                .where((r) => (r['name'] as String).toLowerCase().contains(q))
                .toList();
      }
    });
  }

  void _onTileTap(Map<String, dynamic> rest) {
    setState(() {
      if (_selected.contains(rest)) {
        _selected.remove(rest);
      } else if (_selected.length < 3) {
        _selected.add(rest);
      }
    });
  }

  Future<void> _onNextPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final names = _selected.map((r) => r['name'] as String).toList();
    await prefs.setStringList('top_picks', names);
    // Navigate to the listing page:
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantListingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Top 3'),
        backgroundColor: const Color(0xFF5731EA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Select the best 3 restaurants you've visited",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search restaurants',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredRestaurants.length,
                  itemBuilder: (ctx, i) {
                    final rest = _filteredRestaurants[i];
                    final selected = _selected.contains(rest);

                    return GestureDetector(
                      onTap: () => _onTileTap(rest),
                      child: Stack(
                        children: [
                          // Image background
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              rest['image'] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Selection border overlay
                          if (selected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF5731EA),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),

                          // Check icon
                          if (selected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFF5731EA),
                              ),
                            ),

                          // Name & users badge
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rest['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: rest['color'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rest['users'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selected.length == 3 ? _onNextPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5731EA),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
