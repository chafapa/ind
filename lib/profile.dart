import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation.dart';
import 'package:ind/services/firebase_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3;
  final FirebaseService _firebaseService = FirebaseService();
  
  // User data
  String username = "You";
  String userHandle = "@username";
  String profileImage = 'assets/profile.png';
  double rewardsAmount = 0.0;

  // Data collections
  List<Map<String, dynamic>> topPlaces = [];
  List<Map<String, dynamic>> myRatings = [];
  List<String> photos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      final userProfile = await _firebaseService.getUserProfile();
      if (userProfile.isNotEmpty) {
        setState(() {
          username = userProfile['name'] ?? 'You';
          userHandle = userProfile['handle'] ?? '@username';
          if (userProfile.containsKey('profileImage') && userProfile['profileImage'] != null) {
            profileImage = userProfile['profileImage'];
          }
        });
      }

      // Load rewards
      final rewards = await _firebaseService.getUserRewards();
      setState(() {
        rewardsAmount = rewards;
      });

      // Load top places
      final places = await _firebaseService.getTopPlaces();
      setState(() {
        topPlaces = places;
      });

      // Load user ratings
      final ratings = await _firebaseService.getUserRatings();
      setState(() {
        myRatings = ratings;
      });

      // Load user photos
      final userPhotos = await _firebaseService.getUserPhotos();
      setState(() {
        photos = userPhotos;
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/map',
        (r) => r.settings.name == '/home',
      );
    } else if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/leaderboard',
        (r) => r.settings.name == '/home',
      );
    } else if (index == 3) {
      // already here
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF6200EA),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Status bar with logout
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/home');
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (r) => false,
                                      );
                                    },
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Profile section
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Column(
                                children: [
                                  // Profile picture
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[600],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.purple[500],
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundImage: profileImage.startsWith('assets/')
                                            ? AssetImage(profileImage) as ImageProvider
                                            : NetworkImage(profileImage),
                                      ),
                                    ),
                                  ),

                                  // Username
                                  const SizedBox(height: 16),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    userHandle,
                                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.white,
                            unselectedLabelColor: Colors.white60,
                            labelColor: Colors.white,
                            tabs: const [
                              Tab(text: "My leaderboard"),
                              Tab(text: "Favourites"),
                              Tab(text: "Photos"),
                            ],
                          ),
                          const Color(0xFF6200EA),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // My leaderboard tab
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rewards section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.purple[700],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Redeem ",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "🎁",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                        Text(
                                          "wards",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[900],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        "C\$${rewardsAmount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Redeem Rewards",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Top Places
                              const Text(
                                "Top Places",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: topPlaces.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text("No top places found"),
                                        ),
                                      )
                                    : ListView.separated(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: topPlaces.length,
                                        separatorBuilder:
                                            (context, index) => const Divider(),
                                        itemBuilder: (context, index) {
                                          final place = topPlaces[index];
                                          return ListTile(
                                            leading: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "${index + 1}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  backgroundImage: place['image'] != null && 
                                                                  place['image'].toString().isNotEmpty
                                                      ? NetworkImage(place['image'])
                                                      : const AssetImage('assets/placeholder.png') as ImageProvider,
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              place['name'] ?? "Unknown",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${place['rating']}",
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),

                              const SizedBox(height: 24),

                              // My Ratings
                              const Text(
                                "My Ratings",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: myRatings.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text("No ratings found"),
                                        ),
                                      )
                                    : ListView.separated(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: myRatings.length,
                                        separatorBuilder:
                                            (context, index) => const Divider(),
                                        itemBuilder: (context, index) {
                                          final rating = myRatings[index];
                                          final Map<String, dynamic> ratings =
                                              rating['ratings'] ?? {};

                                          // Calculate average rating
                                          double avgRating = 0;
                                          if (ratings.isNotEmpty) {
                                            double sum = 0;
                                            ratings.forEach((key, value) {
                                              if (value is num) {
                                                sum += value;
                                              }
                                            });
                                            avgRating = sum / ratings.length;
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundImage: rating['imageUrl'] != null &&
                                                                      rating['imageUrl'].toString().isNotEmpty
                                                          ? NetworkImage(rating['imageUrl'])
                                                          : const AssetImage('assets/placeholder.png') as ImageProvider,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          rating['restaurantName'] ?? "Unknown Place",
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: List.generate(
                                                            5,
                                                            (i) => Icon(
                                                              i < avgRating.round() ? Icons.star : Icons.star_border,
                                                              color: Colors.amber,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                GridView.count(
                                                  crossAxisCount: 2,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  childAspectRatio: 4,
                                                  children:
                                                      ratings.entries.map<Widget>((
                                                        entry,
                                                      ) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "${entry.key.substring(0, 1).toUpperCase()}${entry.key.substring(1)}:",
                                                              style: const TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${entry.value}",
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors.black87,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }).toList(),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Favourites tab - Implement your favorites functionality here
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: Text(
                              "Favourites",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      // Photos tab
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "My Photos",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "See All",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              photos.isEmpty
                                  ? Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "No photos yet",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 4,
                                          ),
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: photos.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Navigate to detailed photo view
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 300,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(photos[index]),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(photos[index]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: WeRankBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

// SliverPersistentHeader delegate for the tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar, this._backgroundColor);

  final TabBar _tabBar;
  final Color _backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}