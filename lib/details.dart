import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'write_review.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final Map<String, double> ratings = {
      'Taste': 4.0,
      'Service': 4.0,
      'Cleanliness': 4.0,
      'Affordability': 4.0,
      'Ambience': 4.0,
    };

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(restaurant['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: const Color(0xFF5731EA),
                child: SafeArea(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        restaurant['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        restaurant['name'],
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 30),
                          Icon(Icons.star, color: Colors.amber, size: 30),
                          Icon(Icons.star, color: Colors.amber, size: 30),
                          Icon(Icons.star, color: Colors.amber, size: 30),
                          SizedBox(width: 5),
                          Text("4.0", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...ratings.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: entry.value / 5,
                                backgroundColor: Colors.grey[200],
                                color: const Color(0xFF5731EA),
                                minHeight: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(entry.value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .where('restaurantId', isEqualTo: restaurant['id'])
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final comments = snapshot.data!.docs;

                        return ListView(
                          children: comments.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: data['imageUrl'] != null
                                          ? NetworkImage(data['imageUrl'])
                                          : const AssetImage('assets/avatars/default.png') as ImageProvider,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                data['authorName'] ?? 'User',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              const Spacer(),
                                              if (currentUser?.uid == data['authorId'])
                                                PopupMenuButton<String>(
                                                  onSelected: (value) {
                                                    if (value == 'delete') {
                                                      FirebaseFirestore.instance
                                                          .collection('reviews')
                                                          .doc(doc.id)
                                                          .delete();
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            data['comment'] ?? '',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteReviewPage(restaurantId: restaurant['id']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5731EA),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
