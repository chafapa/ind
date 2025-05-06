// lib/screens/location_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/offline_tile_provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const _kLat = 'pinned_lat', _kLng = 'pinned_lng';

  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {};
  Set<TileOverlay> _tileOverlays = {};

  LatLng? _initialCentre;
  bool _loading = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    _initialCentre = await _resolveInitialCentre();
    await _loadRestaurantMarkers();
    if (mounted) setState(() => _loading = false);
  }

  Future<LatLng> _resolveInitialCentre() async {
    final p = await SharedPreferences.getInstance();
    final lat = p.getDouble(_kLat), lng = p.getDouble(_kLng);
    if (lat != null && lng != null) return LatLng(lat, lng);
    try {
      final pos = await Geolocator.getCurrentPosition();
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return const LatLng(7.9465, -1.0232);
    }
  }

  Future<void> _loadRestaurantMarkers() async {
    final snap =
        await FirebaseFirestore.instance.collection('restaurants').get();
    final user = await Geolocator.getCurrentPosition();
    double? bestD;
    String? bestId;

    for (var doc in snap.docs) {
      final d = doc.data();
      final lat = d['lat'] as double?, lng = d['lng'] as double?;
      if (lat == null || lng == null) continue;
      final id = MarkerId(doc.id);
      _markers[id] = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: d['name'] ?? '',
          snippet: 'Tap to see distance',
        ),
        onTap: () => _onMarkerTap(lat, lng, d['name'] ?? ''),
      );

      final dist = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        lat,
        lng,
      );
      if (bestD == null || dist < bestD) {
        bestD = dist;
        bestId = doc.id;
      }
    }

    if (bestId != null && _initialCentre == null) {
      _initialCentre = _markers[MarkerId(bestId)]!.position;
    }
  }

  Future<void> _onMarkerTap(double lat, double lng, String name) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
    );

    final user = await Geolocator.getCurrentPosition();
    final double straight = Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      lat,
      lng,
    );

    const footSpeed = 83.33; 
    const bicycleSpeed = 250.0; 
    const motorbikeSpeed = 666.67; 
    const carSpeed = 833.33; 

    final onFoot = straight;
    final timeFoot = onFoot / footSpeed;
    final byBicycle = straight * 1.10;
    final timeBike = byBicycle / bicycleSpeed;
    final byMotor = straight * 1.05;
    final timeMotor = byMotor / motorbikeSpeed;
    final byCar = straight * 1.20;
    final timeCar = byCar / carSpeed;

    showModalBottomSheet(
      context: context,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildModeRow(
                  Icons.directions_walk,
                  'On foot',
                  onFoot,
                  timeFoot,
                ),
                _buildModeRow(
                  Icons.directions_bike,
                  'By bicycle',
                  byBicycle,
                  timeBike,
                ),
                _buildModeRow(
                  Icons.motorcycle,
                  'By motorbike',
                  byMotor,
                  timeMotor,
                ),
                _buildModeRow(Icons.directions_car, 'By car', byCar, timeCar),
              ],
            ),
          ),
    );
  }

  Widget _buildModeRow(
    IconData icon,
    String label,
    double dist,
    double minutes,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF5731EA)),
          const SizedBox(width: 12),
          Text(
            '$label: ${dist.toStringAsFixed(0)} m, '
            'approx ${minutes.toStringAsFixed(0)} min',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _toggleOffline() {
    setState(() {
      _offline = !_offline;
      if (_offline) {
        _tileOverlays = {
          TileOverlay(
            tileOverlayId: const TileOverlayId('offline'),
            tileProvider: OfflineTileProvider(),
          ),
        };
      } else {
        _tileOverlays = {};
      }
    });
  }

  // @override
  // Widget build(BuildContext ctx) {
  //   if (_loading) {
  //     return const Scaffold(
  //       body: Center(child: CircularProgressIndicator()),
  //     );
  //   }
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Nearby Restaurants'),
  //       actions: [
  //         PopupMenuButton(
  //           icon: const Icon(Icons.more_vert),
  //           onSelected: (_) => _toggleOffline(),
  //           itemBuilder: (_) => [
  //             PopupMenuItem(
  //               value: 'offline',
  //               child: Text(
  //                 _offline ? 'Disable Offline' : 'Enable Offline',
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //     body: GoogleMap(
  //       initialCameraPosition:
  //           CameraPosition(target: _initialCentre!, zoom: 14),
  //       myLocationEnabled: true,
  //       myLocationButtonEnabled: true,
  //       markers: _markers.values.toSet(),
  //       tileOverlays: _tileOverlays,
  //       onMapCreated: (c) {
  //         if (!_controller.isCompleted) _controller.complete(c);
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext ctx) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4527A0), 
          foregroundColor: Colors.white, 
          centerTitle: true,
          title: const Text('Nearby Restaurants'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (_) => _toggleOffline(),
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      value: 'offline',
                      child: Text(
                        _offline ? 'Disable Offline' : 'Enable Offline',
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialCentre!,
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers.values.toSet(),
          tileOverlays: _tileOverlays,
          onMapCreated: (c) {
            if (!_controller.isCompleted) _controller.complete(c);
          },
        ),
      ),
    );
  }
}
