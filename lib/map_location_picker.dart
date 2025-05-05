// lib/map_location_picker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({Key? key}) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  // keys used in SharedPreferences
  static const _kLat = 'pinned_lat';
  static const _kLng = 'pinned_lng';

  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _pinned; // marker that is shown
  bool _waiting = true; // true while we fetch GPS / prefs

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    // 1. read any saved pin
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kLat);
    final lng = prefs.getDouble(_kLng);
    if (lat != null && lng != null) _pinned = LatLng(lat, lng);

    // 2. fetch current location (permission handled internally)
    try {
      final pos = await _getCurrentPosition();
      _pinned ??= LatLng(pos.latitude, pos.longitude); // fall back to GPS
    } catch (_) {
      // ignore – GPS denied/offline; we'll fall back to Ghana centre
    }

    // 3. un‑block the UI
    setState(() => _waiting = false);

    // 4. **NOW** jump the camera – but in the next frame
    if (_pinned != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return; // widget might be gone
        final c = await _controller.future; // wait for controller
        c.animateCamera(CameraUpdate.newLatLng(_pinned!));
      });
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

  /// Decides where the camera starts:
  Future<CameraPosition> _initialCamera() async {
    if (_pinned != null) {
      return CameraPosition(target: _pinned!, zoom: 15);
    }
    // Fallback: Ghana centre so the map shows something
    return const CameraPosition(target: LatLng(7.9465, -1.0232), zoom: 6);
  }

  Future<void> _savePin(LatLng latLng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLat, latLng.latitude);
    await prefs.setDouble(_kLng, latLng.longitude);
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    const double h = 120;

    if (_waiting) {
      return SizedBox(height: h, width: double.infinity, child: _placeholder());
    }

    return FutureBuilder<CameraPosition>(
      future: _initialCamera(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: h,
            width: double.infinity,
            child: _placeholder(),
          );
        }

        return SizedBox(
          height: h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: snapshot.data!,
              liteModeEnabled: false, 
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                if (_pinned != null)
                  Marker(
                    markerId: const MarkerId('pinned'),
                    position: _pinned!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet,
                    ),
                  ),
              },
              onTap: (LatLng latLng) async {
                setState(() => _pinned = latLng);
                await _savePin(latLng);
                final controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newLatLng(latLng));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location pinned!')),
                );
              },
              onMapCreated: (c) => _controller.complete(c),
            ),
          ),
        );
      },
    );
  }

  // shows the original green card with a location icon
  Widget _placeholder() => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/map_placeholder.png',
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(color: const Color(0xFFE8F5E9)),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF4527A0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
          ),
        ),
      ],
    ),
  );
}
