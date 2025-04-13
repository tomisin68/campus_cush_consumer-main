import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:campus_cush_consumer/bookings.dart';
import 'package:campus_cush_consumer/chat_page.dart';
import 'package:campus_cush_consumer/profile_page.dart';
import 'package:campus_cush_consumer/explore_page.dart';
import 'package:campus_cush_consumer/saved.dart'; // Add other pages for navigation


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Animation controllers for like and save buttons
  late AnimationController _likeController;
  late AnimationController _saveController;
  
  // Track liked and saved states
  final Map<String, bool> _likedStatus = {};
  final Map<String, bool> _savedStatus = {};

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(vsync: this);
    _saveController = AnimationController(vsync: this);
    
    // Initialize all hostel cards as not liked/saved
    for (var image in ['house1', 'house2', 'house3', 'house4', 'house5']) {
      _likedStatus[image] = false;
      _savedStatus[image] = false;
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    _saveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 24),
            _buildFeaturedListings(),
            const SizedBox(height: 24),
            _buildCategoryNavigation(),
            const SizedBox(height: 24),
            _buildRecentListings(),
            const SizedBox(height: 24),
            _buildTrustIndicators(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Campus cush',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _searchExpanded = !_searchExpanded;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
            // Implement chat functionality
          },
        ),
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _searchExpanded ? 120 : 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1F33),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _searchExpanded ? _expandedSearch() : _collapsedSearch(),
          ),
          if (!_searchExpanded) const SizedBox(height: 12),
          if (!_searchExpanded) _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _collapsedSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search hostels...',
        hintStyle: const TextStyle(color: Colors.white54),
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune, color: Colors.white54),
          onPressed: () {
            // Show filter modal
            _showFilterModal(context);
          },
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onTap: () {
        setState(() {
          _searchExpanded = true;
        });
      },
      onSubmitted: (value) {
        // Implement search functionality
        _performSearch(value);
      },
    );
  }

  Widget _expandedSearch() {
    return Column(
      children: [
        _collapsedSearch(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.white12, height: 1),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Any dates',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.people, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Text(
                  '1 guest',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

 void _showFilterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1D1F33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          double priceRange = 100;
          bool wifi = false;
          bool breakfast = false;
          bool privateBathroom = false;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Price Range',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Slider(
                  value: priceRange,
                  min: 0,
                  max: 500,
                  divisions: 10,
                  label: '\$${priceRange.round()}',
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setModalState(() {
                      priceRange = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Free WiFi',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: wifi,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setModalState(() {
                      wifi = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text(
                    'Breakfast Included',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: breakfast,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setModalState(() {
                      breakfast = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text(
                    'Private Bathroom',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: privateBathroom,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setModalState(() {
                      privateBathroom = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // Apply filters
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  void _performSearch(String query) {
    // Implement search functionality
    debugPrint('Searching for: $query');
    // You would typically filter your data here and update the UI
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Under \$20', Icons.attach_money),
          const SizedBox(width: 8),
          _buildFilterChip('Near me', Icons.location_on),
          const SizedBox(width: 8),
          _buildFilterChip('Private rooms', Icons.king_bed),
          const SizedBox(width: 8),
          _buildFilterChip('Free WiFi', Icons.wifi),
          const SizedBox(width: 8),
          _buildFilterChip('Breakfast', Icons.free_breakfast),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    bool selected = false;
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      backgroundColor: const Color(0xFF1D1F33),
      // ignore: dead_code
      labelStyle: TextStyle(color: selected ? Colors.blueAccent : Colors.white),
      selected: selected,
      onSelected: (bool value) {
        // Implement filter functionality
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        // ignore: dead_code
        side: BorderSide(color: selected ? Colors.blueAccent : Colors.white12),
      ),
      selectedColor: const Color(0xFF1D1F33),
      checkmarkColor: Colors.blueAccent,
    );
  }

  Widget _buildFeaturedListings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Featured Hostels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildHostelCard('house1', 'Urban Haven', 'Downtown', 4.8, 45),
              const SizedBox(width: 16),
              _buildHostelCard('house2', 'Mountain View', 'Alpine District', 4.9, 65),
              const SizedBox(width: 16),
              _buildHostelCard('house3', 'Beach Bunker', 'Coastal Area', 4.7, 55),
              const SizedBox(width: 16),
              _buildHostelCard('house4', 'The Loft', 'Arts District', 4.6, 49),
              const SizedBox(width: 16),
              _buildHostelCard('house5', 'Garden Retreat', 'Suburbs', 4.5, 39),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostelCard(String image, String name, String location, double rating, int price) {
    return GestureDetector(
      onTap: () => _navigateToHostelDetails(),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1F33),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/$image.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$$price/night',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          // Save button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _savedStatus[image] = !_savedStatus[image]!;
                              });
                            },
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Lottie.asset(
                                'assets/saved.json',
                                controller: _saveController,
                                animate: _savedStatus[image]!,
                                onLoaded: (composition) {
                                  _saveController
                                    ..duration = composition.duration
                                    ..forward(from: 0);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Like button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _likedStatus[image] = !_likedStatus[image]!;
                              });
                            },
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Lottie.asset(
                                'assets/love.json',
                                controller: _likeController,
                                animate: _likedStatus[image]!,
                                onLoaded: (composition) {
                                  _likeController
                                    ..duration = composition.duration
                                    ..forward(from: 0);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Colors.white54, size: 14),
                          const SizedBox(width: 8),
                          const Icon(Icons.local_dining, color: Colors.white54, size: 14),
                          const SizedBox(width: 8),
                          const Icon(Icons.ac_unit, color: Colors.white54, size: 14),
                        ],
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
  }

  Widget _buildCategoryNavigation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Explore by Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryItem(Icons.beach_access, 'Beach'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.landscape, 'Mountain'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.apartment, 'City'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.forest, 'Forest'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.castle, 'Historic'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.directions_bike, 'Adventure'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              _buildLocationChip('New York'),
              _buildLocationChip('Tokyo'),
              _buildLocationChip('Paris'),
              _buildLocationChip('Barcelona'),
              _buildLocationChip('Sydney'),
              _buildLocationChip('Berlin'),
              _buildLocationChip('Bali'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1D1F33),
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2D40), Color(0xFF1D1F33)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String city) {
    return Chip(
      label: Text(city),
      backgroundColor: Colors.transparent,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }

  Widget _buildRecentListings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New on Hostelio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildVerticalHostelCard('house3', 'Beach Bunker', 'Coastal Area', 4.7, 55),
              const SizedBox(height: 16),
              _buildVerticalHostelCard('house5', 'Garden Retreat', 'Suburbs', 4.5, 39),
              const SizedBox(height: 16),
              _buildVerticalHostelCard('house2', 'Mountain View', 'Alpine District', 4.9, 65),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalHostelCard(String image, String name, String location, double rating, int price) {
    return GestureDetector(
      onTap: () => _navigateToHostelDetails(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1F33),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(
                'assets/$image.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            // Save button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _savedStatus[image] = !_savedStatus[image]!;
                                });
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Lottie.asset(
                                  'assets/saved.json',
                                  controller: _saveController,
                                  animate: _savedStatus[image]!,
                                  onLoaded: (composition) {
                                    _saveController
                                      ..duration = composition.duration
                                      ..forward(from: 0);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Like button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _likedStatus[image] = !_likedStatus[image]!;
                                });
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Lottie.asset(
                                  'assets/love.json',
                                  controller: _likeController,
                                  animate: _likedStatus[image]!,
                                  onLoaded: (composition) {
                                    _likeController
                                      ..duration = composition.duration
                                      ..forward(from: 0);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$$price',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '/night',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2D40), Color(0xFF1D1F33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Verified Hostels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'All our hostels undergo a 15-point verification process including safety checks, amenities validation, and guest reviews to ensure quality stays.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Learn more',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Handle navigation to different pages
          switch (index) {
            case 0:
              // Already on home page
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExplorePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingsPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 0
                  ? BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.search),
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.favorite_border),
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 3
                  ? BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.calendar_today),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 4
                  ? BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateToHostelDetails() {
    // Implement navigation to hostel details
    debugPrint('Navigating to hostel details');
  }
}