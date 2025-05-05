// lib/screens/location_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // ---------------------------------------------------------------------------
  static const _kLat = 'pinned_lat';
  static const _kLng = 'pinned_lng';

  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {};

  LatLng? _initialCentre;
  bool    _loading = true;

  // ===========================================================================
  @override
  void initState() {
    super.initState();
    debugPrint('▶️ LocationScreen initState → _initialise()');
    _initialise();
  }

  // ===========================================================================
  Future<void> _initialise() async {
    try {
      _initialCentre = await _resolveInitialCentre();
      debugPrint('✅ Initial centre resolved: $_initialCentre');

      await _loadRestaurantMarkers();
      debugPrint('✅ Markers loaded: ${_markers.length}');
    } catch (e, st) {
      debugPrint('❌ Error in _initialise → $e');
      debugPrintStack(stackTrace: st);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  Future<LatLng> _resolveInitialCentre() async {
    final prefs  = await SharedPreferences.getInstance();
    final pinLat = prefs.getDouble(_kLat);
    final pinLng = prefs.getDouble(_kLng);

    if (pinLat != null && pinLng != null) {
      debugPrint('ℹ️ Using saved pin $pinLat,$pinLng');
      return LatLng(pinLat, pinLng);
    }

    try {
      final pos = await _getCurrentPosition();
      debugPrint('ℹ️ Using live GPS ${pos.latitude},${pos.longitude}');
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      debugPrint('⚠️ Location denied → falling back to Ghana centre');
      return const LatLng(7.9465, -1.0232);
    }
  }

  Future<Position> _getCurrentPosition() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    return Geolocator.getCurrentPosition();
  }

  // ===========================================================================
  Future<void> _loadRestaurantMarkers() async {
    debugPrint('📡 Fetching restaurants from Firestore…');
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .get();
    debugPrint('📄 Fetched ${snapshot.docs.length} docs');

    final userPos = await _getCurrentPosition();
    final userLat = userPos.latitude;
    final userLng = userPos.longitude;

    double? bestDistance;
    String? bestDocId;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final lat  = data['lat'];
      final lng  = data['lng'];
      if (lat == null || lng == null) {
        debugPrint('↩️  ${doc.id} skipped (no lat/lng)');
        continue;
      }

      final markerId = MarkerId(doc.id);
      _markers[markerId] = Marker(
        markerId: markerId,
        position: LatLng(lat as double, lng as double),
        infoWindow: InfoWindow(
          title: data['name'] ?? 'Restaurant',
          snippet: 'Tap for details',
        ),
        onTap: () => _controller.future.then(
          (c) => c.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lng), zoom: 16),
          )),
        ),
      );

      final dist = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      debugPrint('→ ${data['name']}  dist=${dist.toStringAsFixed(1)} m');

      if (bestDistance == null || dist < bestDistance) {
        bestDistance = dist;
        bestDocId    = doc.id;
      }
    }

    if (bestDocId != null && _initialCentre == null) {
      final nearest = _markers[MarkerId(bestDocId)]!;
      _initialCentre = nearest.position;
      debugPrint('⭐ Nearest = $bestDocId  (${bestDistance!.toStringAsFixed(1)} m)');
    }
  }

  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        backgroundColor: const Color(0xFF4527A0),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialCentre!, zoom: 14),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers.values.toSet(),
        onMapCreated: (c) {
          debugPrint('🗺️ GoogleMap created');
          if (!_controller.isCompleted) _controller.complete(c);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4527A0),
        child: const Icon(Icons.my_location),
        onPressed: () async {
          final pos = await _getCurrentPosition();
          debugPrint('📍 FAB → centring on user ${pos.latitude},${pos.longitude}');
          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
          );
        },
      ),
    );
  }
}
