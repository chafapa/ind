import 'package:flutter/material.dart';
import 'write_review.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsScreen({Key? key, required this.restaurant})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Rating values for this restaurant (all 4.0 as shown in the design)
    final Map<String, double> ratings = {
      'Taste': 4.0,
      'Service': 4.0,
      'Cleanliness': 4.0,
      'Affordability': 4.0,
      'Ambience': 4.0,
    };

    // Comments for the restaurant
    final List<Map<String, dynamic>> comments = [
      {
        'name': 'Alex',
        'comment': 'A cozy spot wit great food!',
        'time': '40 min',
        'avatar': 'assets/avatars/alex.png',
      },
      {
        'name': 'Maria',
        'comment': 'Friendly staff and nice atmosphere',
        'time': '16 min',
        'avatar': 'assets/avatars/maria.png',
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          // Top portion with image and header
          Stack(
            children: [
              // Restaurant image
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

              // Purple header bar
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: const Color(0xFF5731EA),
                child: SafeArea(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        restaurant['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // White card with details
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name and rating
                    Row(
                      children: [
                        Text(
                          restaurant['name'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 30),
                            Icon(Icons.star, color: Colors.amber, size: 30),
                            Icon(Icons.star, color: Colors.amber, size: 30),
                            Icon(Icons.star, color: Colors.amber, size: 30),
                            SizedBox(width: 5),
                            Text(
                              "4.0",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Rating bars
                    ...ratings.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
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
                                      minHeight: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),

                    const SizedBox(height: 20),

                    // Comments section
                    ...comments
                        .map(
                          (comment) => Padding(
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
                                    backgroundImage: AssetImage(
                                      comment['avatar'],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              comment['time'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          comment['comment'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),

          // Write a Review button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => WriteReviewPage(restaurantId: restaurant['id']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5731EA),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
