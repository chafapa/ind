import 'package:flutter/material.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantName;
  final String imageUrl;
  final double overallRating;
  final Map<String, double> ratings;
  final List<Review> reviews;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantName,
    required this.imageUrl,
    required this.overallRating,
    required this.ratings,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0), // Deep purple from the code
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          restaurantName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 80, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            // White Card Content
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Star Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          if (index < overallRating.floor()) {
                            return const Icon(Icons.star, color: Color(0xFFFFC107), size: 28);
                          } else if (index == overallRating.floor() && 
                                      overallRating - overallRating.floor() > 0) {
                            return const Icon(Icons.star_half, color: Color(0xFFFFC107), size: 28);
                          } else {
                            return const Icon(Icons.star_border, color: Color(0xFFFFC107), size: 28);
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          overallRating.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Rating Bars
                    ...ratings.entries.map((entry) => RatingBarWithValue(
                          label: entry.key,
                          value: entry.value,
                          ratingValue: entry.value * 5, // Converting to 5-star scale
                        )),
                    const SizedBox(height: 20),
                    // Reviews Section
                    ...reviews.map((review) => ReviewCard(review: review)),
                    const SizedBox(height: 16),
                    // Write a Review Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Write a review functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4527A0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingBarWithValue extends StatelessWidget {
  final String label;
  final double value;
  final double ratingValue;

  const RatingBarWithValue({
    super.key,
    required this.label,
    required this.value,
    required this.ratingValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Background bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Filled portion
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.5 * value,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4527A0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            ratingValue.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String name;
  final String comment;
  final String timeAgo;
  final String avatarUrl;

  Review({
    required this.name,
    required this.comment,
    required this.timeAgo,
    required this.avatarUrl,
  });
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(review.avatarUrl),
            onBackgroundImageError: (exception, stackTrace) {},
            child: const Icon(Icons.person, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Review Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to use the page
class RestaurantDetailExample extends StatelessWidget {
  const RestaurantDetailExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RestaurantDetailPage(
        restaurantName: 'Bistro 22',
        imageUrl: 'assets/images/bistro.jpg',
        overallRating: 4.0,
        ratings: {
          'Taste': 0.8,
          'Service': 0.8,
          'Cleanliness': 0.8,
          'Affordability': 0.7,
          'Ambience': 0.6,
        },
        reviews: [
          Review(
            name: 'Alex',
            comment: 'A cozy spot wit great food!',
            timeAgo: '40 min',
            avatarUrl: 'assets/images/avatar1.png',
          ),
          Review(
            name: 'Maria',
            comment: 'Friendly staff and nice atmosphere',
            timeAgo: '16 min',
            avatarUrl: 'assets/images/avatar2.png',
          ),
        ],
      ),
    );
  }
}