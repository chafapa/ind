import 'package:flutter/material.dart';
import 'preferences.dart';
// ignore: unused_import
import 'data/restaurants_data.dart';
import 'navigation.dart';
import 'details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'map_location_picker.dart';
import 'payment_page.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final String points;
  final String imageUrl;
  final Map<String, dynamic> fullRestaurantData;
  final Map<String, double> ratings;
  final bool hasComment;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.points,
    required this.imageUrl,
    required this.ratings,
    required this.fullRestaurantData,
    this.hasComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    RestaurantDetailsScreen(restaurant: fullRestaurantData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Restaurant Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              points,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Rating Bars
                        ...ratings.entries.map(
                          (entry) => RatingBar(
                            label: entry.key,
                            value: entry.value,
                            hasComment: hasComment && entry.key == 'Ambience',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final String label;
  final double value;
  final bool hasComment;

  const RatingBar({
    super.key,
    required this.label,
    required this.value,
    this.hasComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Stack(
              children: [
                // Background bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Filled portion
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width * 0.4 * value,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4527A0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          if (hasComment)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Colors.amber,
              ),

              // Image.asset(
              //   'assets/images/comment.png',
              //   width: 20,
              //   height: 20,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(
              //       Icons.chat_bubble_outline,
              //       size: 20,
              //       color: Colors.amber,
              //     );
              //   },
              // ),
            ),
        ],
      ),
    );
  }
}

class RestaurantListingPage extends StatefulWidget {
  final bool showBackButton;

  const RestaurantListingPage({
    Key? key,
    this.showBackButton = true, // Default to true if not passed
  }) : super(key: key);

  @override
  State<RestaurantListingPage> createState() => _RestaurantListingPageState();
}

class _RestaurantListingPageState extends State<RestaurantListingPage> {
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // Track the current navigation index (Home is 0)

  @override
  void initState() {
    super.initState();
    _loadAndReorder();
    _searchController.addListener(_filterRestaurants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAndReorder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final picks = AppPreferences.getTopPicks();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();
      final docs = snapshot.docs;

      final restaurants =
          docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Unknown',
              'users': data['users']?.toString() ?? '0',
              'image': data['image'] ?? 'assets/images/default.png',
              'ratings': Map<String, double>.from(data['ratings'] ?? {}),
              'colorHex': data['colorHex'] ?? '#FFFFFF',
            };
          }).toList();

      // Save to local cache
      await prefs.setString('cached_restaurants', jsonEncode(restaurants));

      final selected =
          restaurants.where((r) => picks.contains(r['name'])).toList();
      final others =
          restaurants.where((r) => !picks.contains(r['name'])).toList();

      setState(() {
        _restaurants = [...selected, ...others];
        _filteredRestaurants = _restaurants;
      });
    } catch (e) {
      print('Firestore failed: $e');
      // Try to load from local cache
      final cachedData = prefs.getString('cached_restaurants');
      if (cachedData != null) {
        final decoded = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
        final selected =
            decoded.where((r) => picks.contains(r['name'])).toList();
        final others =
            decoded.where((r) => !picks.contains(r['name'])).toList();

        setState(() {
          _restaurants = [...selected, ...others];
          _filteredRestaurants = _restaurants;
        });
      } else {
        // Fallback to hardcoded local data
        final selected =
            defaultRestaurantData
                .where((r) => picks.contains(r['name']))
                .toList();
        final others =
            defaultRestaurantData
                .where((r) => !picks.contains(r['name']))
                .toList();

        setState(() {
          _restaurants = [...selected, ...others];
          _filteredRestaurants = _restaurants;
        });
      }
    }
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants =
            _restaurants
                .where(
                  (r) => (r['name'] as String).toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  // Navigation handler
  // void _onNavTap(int index) {
  //   if (index == _currentIndex) return; // Skip if already on this page

  //   setState(() {
  //     _currentIndex = index;
  //   });

  //   if (index == 0) {
  //     // Explicitly navigate to home (if needed)
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const RestaurantListingPage(showBackButton: false),
  //       ),
  //     );
  //   } else if (index == 1) {
  //     Navigator.pushNamed(context, '/map');
  //   } else if (index == 2) {
  //     Navigator.pushNamed(context, '/leaderboard');
  //   } else if (index == 3) {
  //     Navigator.pushNamed(context, '/profile');
  //   }
  // }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/map',
        (route) => route.settings.name == '/home',
      );
    } else if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/leaderboard',
        (route) => route.settings.name == '/home',
      );
    } else if (index == 3) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/profile',
        (route) => route.settings.name == '/home',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4527A0),
        foregroundColor: Colors.white,

        centerTitle: true,
        title: const Text(
          'WeRank',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment), // ← payment icon now
            tooltip: 'Pay with MoMo', // ← helpful tooltip
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Pay with MoMo'),
                      content: const Text('Proceed to Mobile Money payment?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PaymentPage(),
                              ),
                            );
                          },
                          child: const Text('Pay with MoMo'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // Map view - always showing as a peek view
                const MapLocationPicker(),
              ],
            ),
          ),

          // Restaurant list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                if (i >= _filteredRestaurants.length) return null;
                final r = _filteredRestaurants[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RestaurantCard(
                    name: r['name'] as String,
                    points: r['users'] as String,
                    imageUrl: r['image'] as String,
                    ratings: r['ratings'] as Map<String, double>? ?? {},
                    fullRestaurantData: r,
                    hasComment:
                        (r['color'] as Color?) == const Color(0xFF5731EA),
                  ),
                );
              }, childCount: _filteredRestaurants.length),
            ),
          ),
        ],
      ),
      // Add the navigation bar at the bottom
      bottomNavigationBar: WeRankBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
