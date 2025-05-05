import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'write_review.dart';
import 'full_review_page.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsScreen({Key? key, required this.restaurant})
    : super(key: key);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final FlutterTts flutterTts = FlutterTts(); // Text-to-Speech

  final Map<String, double> ratings = {
    'Taste': 4.0,
    'Service': 4.0,
    'Cleanliness': 4.0,
    'Affordability': 4.0,
    'Ambience': 4.0,
  };

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, _) => [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF5731EA),
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(widget.restaurant['name']),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(color: Color(0xFF5731EA)),
                    child: Column(
                      children: [
                        Image.asset(
                          widget.restaurant['image'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.restaurant['name'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "4.0",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      ratings.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: entry.value / 5,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF5731EA),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('reviews')
                              .where(
                                'restaurantId',
                                isEqualTo: widget.restaurant['id'],
                              )
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5731EA),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No reviews yet.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        final reviews = snapshot.data!.docs;
                        return Column(
                          children:
                              reviews.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final isAuthor =
                                    currentUser != null &&
                                    data['authorId'] == currentUser!.uid;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 24,
                                          backgroundImage: AssetImage(
                                            'assets/avatars/default.png',
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    data['authorName'] ??
                                                        'Anonymous',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  if (isAuthor)
                                                    PopupMenuButton<String>(
                                                      icon: Icon(
                                                        Icons.more_horiz,
                                                        color: Colors.grey[400],
                                                      ),
                                                      onSelected: (value) {
                                                        if (value == 'delete') {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                'reviews',
                                                              )
                                                              .doc(doc.id)
                                                              .delete();
                                                        }
                                                      },
                                                      itemBuilder:
                                                          (context) => [
                                                            const PopupMenuItem(
                                                              value: 'delete',
                                                              child: Text(
                                                                'Delete review',
                                                              ),
                                                            ),
                                                          ],
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  _,
                                                                ) => FullReviewPage(
                                                                  comment:
                                                                      data['comment'] ??
                                                                      '',
                                                                  imageUrl:
                                                                      data['imageUrl'],
                                                                ),
                                                          ),
                                                        );
                                                      },

                                                      child: Text(
                                                        (data['comment'] ?? '')
                                                                    .length >
                                                                100
                                                            ? '${(data['comment'] as String).substring(0, 100)}...'
                                                            : data['comment'] ??
                                                                '',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[800],
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.volume_up,
                                                      color: Color(0xFF5731EA),
                                                    ),
                                                    onPressed: () {
                                                      flutterTts.speak(
                                                        data['comment'] ?? '',
                                                      );
                                                    },
                                                  ),
                                                ],
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
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => WriteReviewPage(
                              restaurantId: widget.restaurant['id'],
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5731EA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Write a Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showReviewDialog(
    BuildContext context,
    String comment,
    String? imageUrl,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(comment, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(color: Color(0xFF5731EA)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
