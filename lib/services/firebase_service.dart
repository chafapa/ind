// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;

  /// Returns the current user's UID, or null if not signed in.
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Fetches the user profile from Firestore.
  /// Falls back to Firebase Auth data if no document exists.
  Future<Map<String, dynamic>> getUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    final docSnap = await _firestore.collection('users').doc(uid).get();
    if (!docSnap.exists || docSnap.data() == null) {
      // Fallback to Auth user info
      final user = _auth.currentUser!;
      final displayName = user.displayName ?? user.email!.split('@')[0];
      return {
        'name': displayName,
        'handle': '@${displayName.toLowerCase()}',
        'profileImage': null,
        'rewards': 0.0,
      };
    }

    return docSnap.data()!;
  }

  /// Retrieves all reviews by the current user, enriching each with its restaurant name.
  Future<List<Map<String, dynamic>>> getUserRatings() async {
    final uid = getCurrentUserId();
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('reviews')
        .where('authorId', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> ratings = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      String restaurantName = 'Unknown Place';

      if (data.containsKey('restaurantId')) {
        final restDoc = await _firestore
            .collection('restaurants')
            .doc(data['restaurantId'])
            .get();
        if (restDoc.exists) {
          final restData = restDoc.data();
          if (restData != null && restData.containsKey('name')) {
            restaurantName = restData['name'];
          }
        }
      }

      ratings.add({
        'id': doc.id,
        'restaurantName': restaurantName,
        ...data,
      });
    }

    return ratings;
  }

  /// Retrieves all photo URLs from the current user's reviews.
  Future<List<String>> getUserPhotos() async {
    final uid = getCurrentUserId();
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('reviews')
        .where('authorId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['imageUrl'] as String?)
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Calculates the top-rated restaurants across all reviews.
  Future<List<Map<String, dynamic>>> getTopPlaces() async {
    final reviewsSnap     = await _firestore.collection('reviews').get();
    final restaurantsSnap = await _firestore.collection('restaurants').get();

    // Aggregate ratings per restaurant
    final Map<String, List<double>> aggRatings = {};
    for (var doc in reviewsSnap.docs) {
      final data = doc.data();
      if (data.containsKey('restaurantId') && data.containsKey('ratings')) {
        final rid = data['restaurantId'] as String;
        final ratingsMap = Map<String, dynamic>.from(data['ratings']);
        final avg = ratingsMap.values
            .whereType<num>()
            .map((v) => v.toDouble())
            .fold(0.0, (a, b) => a + b) /
            ratingsMap.length;

        aggRatings.putIfAbsent(rid, () => []).add(avg);
      }
    }

    // Build list with final averages and metadata
    final List<Map<String, dynamic>> results = [];
    for (var restDoc in restaurantsSnap.docs) {
      final rid = restDoc.id;
      if (!aggRatings.containsKey(rid)) continue;
      final list = aggRatings[rid]!;
      final overallAvg = list.fold(0.0, (a, b) => a + b) / list.length;

      final data = restDoc.data();
      results.add({
        'id': rid,
        'name': data['name'] ?? 'Unknown Restaurant',
        'image': data['imageUrl'] ?? '',
        'rating': double.parse(overallAvg.toStringAsFixed(1)),
      });
    }

    // Sort descending and limit to top 5
    results.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    return results.take(5).toList();
  }

  /// Fetches the current user's reward balance.
  Future<double> getUserRewards() async {
    final uid = getCurrentUserId();
    if (uid == null) return 0.0;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data.containsKey('rewards')) {
      final r = data['rewards'];
      return (r is num) ? r.toDouble() : 0.0;
    }
    return 0.0;
  }
}
