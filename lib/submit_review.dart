import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  
  // Rating values for each category (1-5)
  final Map<String, int> _ratings = {
    'Taste': 0,
    'Service': 0,
    'Cleanliness': 0,
    'Affordability': 0,
    'Ambience': 0,
  };
  
  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      print('Error taking picture: $e');
    }
  }

  Future<void> _selectPicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      print('Error selecting picture: $e');
    }
  }

  void _submitReview() {
    // Here you would typically send the review data to your backend
    // For now, we'll just print the values and navigate back
    print('Ratings: $_ratings');
    print('Comment: ${_commentController.text}');
    print('Images: $_images');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0),
        foregroundColor: Colors.white,
        title: const Text(
          'Write a Review',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Categories
              ..._ratings.entries.map((entry) => _buildRatingRow(entry.key)),
              
              const SizedBox(height: 24),
              
              // Comment TextField
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Additional comments',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                maxLines: 4,
              ),
              
              const SizedBox(height: 24),
              
              // Image Selection Row
              Row(
                children: [
                  // Camera Button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF4527A0),
                        size: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Display selected image or placeholder
                  _images.isNotEmpty
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            image: DecorationImage(
                              image: FileImage(File(_images.first)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _selectPicture,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4527A0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRatingRow(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: List.generate(
              5,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _ratings[category] = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    _ratings[category]! > index
                        ? Icons.star
                        : Icons.star_border,
                    color:
                        _ratings[category]! > index ? Colors.amber : Colors.grey[300],
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}