import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'preferences.dart';
import 'home.dart';


// class LocationScreen extends StatefulWidget {
//   const LocationScreen({Key? key}) : super(key: key);

//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }

// class _LocationScreenState extends State<LocationScreen> {
//   late GoogleMapController mapController;
//   LatLng? _selectedLocation;
//   final TextEditingController _searchController = TextEditingController();
//   Set<Marker> _markers = {};
//   List<Location> _locationSuggestions = [];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     if (_searchController.text.length > 2) {
//       _getPlaceSuggestions(_searchController.text);
//     } else {
//       setState(() => _locationSuggestions = []);
//     }
//   }

//   Future<void> _getPlaceSuggestions(String query) async {
//     try {
//       final locations = await locationFromAddress(query);
//       setState(() => _locationSuggestions = locations);
//     } catch (e) {
//       setState(() => _locationSuggestions = []);
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         // Optionally show dialog to enable location services
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           // Optionally show dialog explaining why location is needed
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         // Optionally show dialog to open app settings
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _updateMapPosition(LatLng(position.latitude, position.longitude));
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       // Optionally show error to user
//     }
//   }

//   void _updateMapPosition(LatLng location) {
//     setState(() {
//       _selectedLocation = location;
//       _markers = {
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: location,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       };
//     });
//     mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
//   }

//   Future<String> _getAddressFromLatLng(LatLng latLng) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       final place = placemarks.first;
//       return '${place.street}, ${place.locality}';
//     } catch (e) {
//       return 'Selected Location';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: const Icon(Icons.arrow_back, size: 24),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Choose your location',
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.grey[100],
//                 ),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search',
//                         prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 15,
//                         ),
//                       ),
//                     ),
//                     if (_locationSuggestions.isNotEmpty)
//                       Container(
//                         height: 150,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: ListView.builder(
//                           itemCount: _locationSuggestions.length,
//                           itemBuilder: (context, index) {
//                             final location = _locationSuggestions[index];
//                             return FutureBuilder<String>(
//                               future: _getAddressFromLatLng(
//                                 LatLng(location.latitude, location.longitude),
//                               ),
//                               builder: (context, snapshot) {
//                                 return ListTile(
//                                   title: Text(
//                                     snapshot.data ?? 'Location ${index + 1}',
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   onTap: () {
//                                     _updateMapPosition(
//                                       LatLng(
//                                         location.latitude,
//                                         location.longitude,
//                                       ),
//                                     );
//                                     setState(() => _locationSuggestions = []);
//                                   },
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Stack(
//                     children: [
//                       GoogleMap(
//                         onMapCreated: (controller) {
//                           mapController = controller;
//                           // Initial camera position should be set only if _selectedLocation is not null
//                           if (_selectedLocation != null) {
//                             controller.animateCamera(
//                               CameraUpdate.newLatLngZoom(
//                                 _selectedLocation!,
//                                 15,
//                               ),
//                             );
//                           }
//                         },
//                         initialCameraPosition: CameraPosition(
//                           target:
//                               _selectedLocation ??
//                               const LatLng(0, 0), // Fallback to (0,0) if null
//                           zoom: 15,
//                         ),
//                         markers: _markers,
//                         onTap: _updateMapPosition,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled:
//                             false, // You're providing your own UI
//                         zoomControlsEnabled: false,
//                       ),
//                       Center(
//                         child: Transform.translate(
//                           offset: const Offset(0, -20),
//                           child: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF5731EA),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.location_on,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed:
//                       _selectedLocation == null
//                           ? null
//                           : () async {
//                             await AppPreferences.setLocation(
//                               _selectedLocation!.latitude,
//                               _selectedLocation!.longitude,
//                             );
//                             await AppPreferences.setFirstTimeDone();
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) => const RestaurantListingPage(),
//                               ),
//                             );
//                           },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5731EA),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: const Text(
//                     'Search',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Center(
//                 child: Container(
//                   width: 135,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(2.5),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/restaurant_selection_screen.dart

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
      'color': Colors.grey,
    },
    {
      'name': 'KFC',
      'image': 'assets/kfc.jpg',
      'users': '92 U',
      'color': Colors.grey,
    },
    {
      'name': 'Treehouse Restaurant',
      'image': 'assets/treehouse.jpg',
      'users': '150 U',
      'color': Colors.grey,
    },
    {
      'name': 'Papaye',
      'image': 'assets/papaye.png',
      'users': '92 U',
      'color': Colors.grey,
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
        _filteredRestaurants = _allRestaurants
            .where((r) =>
                (r['name'] as String).toLowerCase().contains(q))
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
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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
                                            color: Colors.white),
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
                  onPressed:
                      _selected.length == 3 ? _onNextPressed : null,
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


