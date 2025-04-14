// ignore_for_file: dead_code, unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:campus_cush_consumer/bookings.dart';
import 'package:campus_cush_consumer/chat_page.dart';
import 'package:campus_cush_consumer/profile_page.dart';
import 'package:campus_cush_consumer/explore_page.dart';
import 'package:campus_cush_consumer/saved.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  // Animation controllers
  late AnimationController _likeController;
  late AnimationController _saveController;

  // Track liked and saved states
  final Map<String, bool> _likedStatus = {};
  final Map<String, bool> _savedStatus = {};

  // Firebase Database
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('hostels');
  List<Hostel> _featuredHostels = [];
  List<Hostel> _recentHostels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(vsync: this);
    _saveController = AnimationController(vsync: this);
    _loadHostels();
  }

  Future<void> _loadHostels() async {
    try {
      // Get featured hostels (first 5)
      final featuredSnapshot = await _databaseRef.limitToFirst(5).get();
      final featuredHostels = _processSnapshot(featuredSnapshot);

      // Get recent hostels (last 3 by createdAt)
      final recentSnapshot =
          await _databaseRef.orderByChild('createdAt').limitToLast(3).get();
      final recentHostels = _processSnapshot(recentSnapshot);

      setState(() {
        _featuredHostels = featuredHostels;
        _recentHostels = recentHostels;
        _isLoading = false;

        // Initialize liked/saved status
        for (var hostel in [..._featuredHostels, ..._recentHostels]) {
          _likedStatus[hostel.id] = false;
          _savedStatus[hostel.id] = false;
        }
      });
    } catch (e) {
      debugPrint('Error loading hostels: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Hostel> _processSnapshot(DataSnapshot snapshot) {
    if (!snapshot.exists) return [];

    final hostelsMap = snapshot.value as Map<dynamic, dynamic>;
    return hostelsMap.entries.map((entry) {
      return Hostel.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
    }).toList();
  }

  @override
  void dispose() {
    _likeController.dispose();
    _saveController.dispose();
    _searchController.dispose();
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
          onPressed: () => _showFilterModal(context),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onTap: () => setState(() => _searchExpanded = true),
      onSubmitted: (value) => _performSearch(value),
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
                      setModalState(() => priceRange = value);
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
                    onChanged: (value) => setModalState(() => wifi = value!),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Breakfast Included',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: breakfast,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) =>
                        setModalState(() => breakfast = value!),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Private Bathroom',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: privateBathroom,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) =>
                        setModalState(() => privateBathroom = value!),
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
    debugPrint('Searching for: $query');
    // Implement search functionality
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Under ₦100k', Icons.attach_money),
          const SizedBox(width: 8),
          _buildFilterChip('Near campus', Icons.location_on),
          const SizedBox(width: 8),
          _buildFilterChip('Private rooms', Icons.king_bed),
          const SizedBox(width: 8),
          _buildFilterChip('Free WiFi', Icons.wifi),
          const SizedBox(width: 8),
          _buildFilterChip('Self-contained', Icons.home),
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
      labelStyle: TextStyle(color: selected ? Colors.blueAccent : Colors.white),
      selected: selected,
      onSelected: (bool value) {
        // Implement filter functionality
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? Colors.blueAccent : Colors.white12),
      ),
      selectedColor: const Color(0xFF1D1F33),
      checkmarkColor: Colors.blueAccent,
    );
  }

  Widget _buildFeaturedListings() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_featuredHostels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No featured hostels available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featuredHostels.length,
            itemBuilder: (context, index) {
              final hostel = _featuredHostels[index];
              return Padding(
                padding: EdgeInsets.only(
                    right: index == _featuredHostels.length - 1 ? 0 : 16),
                child: _buildHostelCard(hostel),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHostelCard(Hostel hostel) {
    return GestureDetector(
      onTap: () => _navigateToHostelDetails(hostel),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: hostel.imageUrls.isNotEmpty
                      ? Image.network(
                          hostel.imageUrls[0],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 160,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          height: 160,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₦${hostel.price}/year',
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
                          hostel.name,
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
                                _savedStatus[hostel.id] =
                                    !_savedStatus[hostel.id]!;
                              });
                            },
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Lottie.asset(
                                'assets/saved.json',
                                controller: _saveController,
                                animate: _savedStatus[hostel.id]!,
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
                                _likedStatus[hostel.id] =
                                    !_likedStatus[hostel.id]!;
                              });
                            },
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Lottie.asset(
                                'assets/love.json',
                                controller: _likeController,
                                animate: _likedStatus[hostel.id]!,
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
                      const Icon(Icons.location_on,
                          color: Colors.blueAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        hostel.location,
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
                        hostel.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (hostel.features.contains('WiFi'))
                            const Icon(Icons.wifi,
                                color: Colors.white54, size: 14),
                          if (hostel.features.contains('WiFi'))
                            const SizedBox(width: 8),
                          if (hostel.features.contains('Kitchen') ||
                              hostel.features.contains('Shared Kitchen'))
                            const Icon(Icons.local_dining,
                                color: Colors.white54, size: 14),
                          if (hostel.features.contains('Kitchen') ||
                              hostel.features.contains('Shared Kitchen'))
                            const SizedBox(width: 8),
                          if (hostel.features.contains('Air Conditioning'))
                            const Icon(Icons.ac_unit,
                                color: Colors.white54, size: 14),
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
              _buildCategoryItem(Icons.home, 'Self-contained'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.apartment, 'Shared'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.king_bed, 'Single Room'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.business, 'Premium'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.people, 'Shared Room'),
              const SizedBox(width: 20),
              _buildCategoryItem(Icons.star, 'Top Rated'),
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
              _buildLocationChip('Main Campus'),
              _buildLocationChip('Oke-Baale'),
              _buildLocationChip('Oke-Fia'),
              _buildLocationChip('Oja-Oba'),
              _buildLocationChip('GRA'),
              _buildLocationChip('Ijebu-Jesa Road'),
              _buildLocationChip('Ilesa Road'),
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recentHostels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No recent hostels available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New on Campus Cush',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentHostels.length,
            itemBuilder: (context, index) {
              final hostel = _recentHostels[index];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == _recentHostels.length - 1 ? 0 : 16),
                child: _buildVerticalHostelCard(hostel),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalHostelCard(Hostel hostel) {
    return GestureDetector(
      onTap: () => _navigateToHostelDetails(hostel),
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
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: hostel.imageUrls.isNotEmpty
                  ? Image.network(
                      hostel.imageUrls[0],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[800],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white),
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
                            hostel.name,
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
                                  _savedStatus[hostel.id] =
                                      !_savedStatus[hostel.id]!;
                                });
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Lottie.asset(
                                  'assets/saved.json',
                                  controller: _saveController,
                                  animate: _savedStatus[hostel.id]!,
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
                                  _likedStatus[hostel.id] =
                                      !_likedStatus[hostel.id]!;
                                });
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Lottie.asset(
                                  'assets/love.json',
                                  controller: _likeController,
                                  animate: _likedStatus[hostel.id]!,
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
                        const Icon(Icons.location_on,
                            color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          hostel.location,
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
                          hostel.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₦${hostel.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '/year',
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
              const Icon(Icons.verified_user,
                  color: Colors.blueAccent, size: 24),
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

  void _navigateToHostelDetails(Hostel hostel) {
    debugPrint('Navigating to details of ${hostel.name}');
    // Implement navigation to hostel details page
  }
}

class Hostel {
  final String id;
  final String name;
  final String type;
  final String location;
  final int price;
  final int unitsTotal;
  final int unitsLeft;
  final List<String> features;
  final String description;
  final List<String> imageUrls;
  final double rating;
  final bool isAvailable;

  Hostel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.unitsTotal,
    required this.unitsLeft,
    required this.features,
    required this.description,
    required this.imageUrls,
    required this.rating,
    required this.isAvailable,
  });

  factory Hostel.fromMap(String id, Map<String, dynamic> map) {
    return Hostel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      price: map['price']?.toInt() ?? 0,
      unitsTotal: map['unitsTotal']?.toInt() ?? 0,
      unitsLeft: map['unitsLeft']?.toInt() ?? 0,
      features: List<String>.from(map['features'] ?? []),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rating: map['rating']?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? false,
    );
  }
}
