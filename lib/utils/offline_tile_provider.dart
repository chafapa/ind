// lib/utils/offline_tile_provider.dart
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OfflineTileProvider implements TileProvider {
  static const _urlTemplate =
    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final z = zoom ?? 14; // or choose a default if zoom ever comes in null
    final url = _urlTemplate
        .replaceFirst('{x}', '$x')
        .replaceFirst('{y}', '$y')
        .replaceFirst('{z}', '$z');

    try {
      // Try online first (will cache the tile)
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      return Tile(256, 256, bytes);
    } catch (_) {
      // If offline or fetch fails, serve from cache only
      final info = await DefaultCacheManager().getFileFromCache(url);
      if (info != null && await info.file.exists()) {
        final bytes = await info.file.readAsBytes();
        return Tile(256, 256, bytes);
      }
      // No tile available
      return Tile(256, 256, Uint8List(0));
    }
  }
}
