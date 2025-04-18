// ignore_for_file: dead_code

import 'dart:math';

import 'package:campus_cush_consumer/bookings.dart';
import 'package:campus_cush_consumer/chat_page.dart';
import 'package:campus_cush_consumer/explore_page.dart';
import 'package:campus_cush_consumer/hostel_detail_page.dart';
import 'package:campus_cush_consumer/profile_page.dart';
import 'package:campus_cush_consumer/saved.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_cush_consumer/models/hostel_model.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Track liked and saved states
  final Map<String, bool> _likedStatus = {};
  final Map<String, bool> _savedStatus = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Hostel> _featuredHostels = [];
  List<Hostel> _recentHostels = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  // Filter states
  double _priceRange = 100;
  bool _wifi = false;
  bool _breakfast = false;
  bool _privateBathroom = false;
  String? _selectedLocation;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadHostels();
    _searchFocusNode.addListener(_handleSearchFocusChange);
  }

  void _handleSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      setState(() => _searchExpanded = true);
    }
  }

  Future<void> _loadHostels() async {
    if (!mounted) return;
    _isLoading.value = true;

    try {
      final results = await Future.wait([
        _getFeaturedHostels(),
        _getRecentHostels(),
      ]);

      final featuredHostels = results[0];
      final recentHostels = results[1];

      if (!mounted) return;

      // Smart random loading algorithm
      final allHostels = [...featuredHostels, ...recentHostels]..shuffle();

      // Apply weighted randomness (featured hostels have higher chance)
      final randomHostels =
          _getWeightedRandomHostels(allHostels, featuredHostels);

      setState(() {
        _featuredHostels = randomHostels.sublist(0, 5);
        _recentHostels = randomHostels.sublist(5);
      });
    } catch (e) {
      debugPrint('Error loading hostels: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load hostels'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadHostels,
            ),
          ),
        );
      }
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  // Weighted random algorithm for hostel loading
  List<Hostel> _getWeightedRandomHostels(
      List<Hostel> allHostels, List<Hostel> featured) {
    final random = Random();
    final weightedList = <Hostel>[];

    // Add featured hostels twice to increase their chance
    weightedList.addAll(allHostels);
    weightedList.addAll(featured);

    // Shuffle with timestamp-based seed for better randomness
    weightedList.shuffle(random);

    // Remove duplicates while preserving order
    return weightedList.toSet().toList();
  }

  Future<List<Hostel>> _getFeaturedHostels() async {
    try {
      final snapshot = await _firestore
          .collection('hostels')
          .where('isAvailable', isEqualTo: true)
          .limit(8)
          .get();
      return _parseHostelDocuments(snapshot.docs);
    } catch (e) {
      debugPrint('Error getting featured hostels: $e');
      return [];
    }
  }

  Future<List<Hostel>> _getRecentHostels() async {
    try {
      QuerySnapshot snapshot;
      try {
        snapshot = await _firestore
            .collection('hostels')
            .where('isAvailable', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          snapshot = await _firestore
              .collection('hostels')
              .where('isAvailable', isEqualTo: true)
              .limit(5)
              .get();
        } else {
          rethrow;
        }
      }
      return _parseHostelDocuments(snapshot.docs);
    } catch (e) {
      debugPrint('Error getting recent hostels: $e');
      return [];
    }
  }

  List<Hostel> _parseHostelDocuments(List<DocumentSnapshot> docs) {
    return docs
        .map((doc) {
          try {
            return Hostel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>);
          } catch (e) {
            debugPrint('Error parsing hostel ${doc.id}: $e');
            return null;
          }
        })
        .whereType<Hostel>()
        .toList();
  }

  void _applyFilters() {
    List<Hostel> filteredFeatured = _featuredHostels;
    List<Hostel> filteredRecent = _recentHostels;

    if (_wifi) {
      filteredFeatured = filteredFeatured
          .where((hostel) => hostel.features.contains('WiFi'))
          .toList();
      filteredRecent = filteredRecent
          .where((hostel) => hostel.features.contains('WiFi'))
          .toList();
    }

    if (_breakfast) {
      filteredFeatured = filteredFeatured
          .where((hostel) => hostel.features.contains('Breakfast Included'))
          .toList();
      filteredRecent = filteredRecent
          .where((hostel) => hostel.features.contains('Breakfast Included'))
          .toList();
    }

    if (_privateBathroom) {
      filteredFeatured = filteredFeatured
          .where((hostel) => hostel.features.contains('Private Bathroom'))
          .toList();
      filteredRecent = filteredRecent
          .where((hostel) => hostel.features.contains('Private Bathroom'))
          .toList();
    }

    if (_priceRange < 500) {
      filteredFeatured = filteredFeatured
          .where((hostel) => hostel.price <= _priceRange)
          .toList();
      filteredRecent = filteredRecent
          .where((hostel) => hostel.price <= _priceRange)
          .toList();
    }

    if (_selectedLocation != null) {
      filteredFeatured = filteredFeatured
          .where((hostel) => hostel.location.contains(_selectedLocation!))
          .toList();
      filteredRecent = filteredRecent
          .where((hostel) => hostel.location.contains(_selectedLocation!))
          .toList();
    }

    setState(() {
      _featuredHostels = filteredFeatured;
      _recentHostels = filteredRecent;
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _loadHostels();
      return;
    }

    final featuredResults = _featuredHostels
        .where((hostel) =>
            hostel.name.toLowerCase().contains(query.toLowerCase()) ||
            hostel.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final recentResults = _recentHostels
        .where((hostel) =>
            hostel.name.toLowerCase().contains(query.toLowerCase()) ||
            hostel.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _featuredHostels = featuredResults;
      _recentHostels = recentResults;
    });
  }

  void _resetFilters() {
    setState(() {
      _priceRange = 100;
      _wifi = false;
      _breakfast = false;
      _privateBathroom = false;
      _selectedLocation = null;
      _selectedCategory = null;
    });
    _loadHostels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) {
          return isLoading
              ? _buildShimmerEffect()
              : SingleChildScrollView(
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
                );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                height: 24,
                width: 200,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[700]!,
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                height: 24,
                width: 200,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[700]!,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 60,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // Remove back button
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
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            // Handle notification tap
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
      focusNode: _searchFocusNode,
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
      onSubmitted: _performSearch,
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
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
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
                    value: _priceRange,
                    min: 0,
                    max: 500,
                    divisions: 10,
                    label: '₦${_priceRange.round()}k',
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setModalState(() => _priceRange = value);
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
                    value: _wifi,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setModalState(() => _wifi = value!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Breakfast Included',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _breakfast,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setModalState(() => _breakfast = value!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Private Bathroom',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _privateBathroom,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setModalState(() => _privateBathroom = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildLocationFilterChip('Main Campus', setModalState),
                        const SizedBox(width: 8),
                        _buildLocationFilterChip('Oke-Baale', setModalState),
                        const SizedBox(width: 8),
                        _buildLocationFilterChip('Oke-Fia', setModalState),
                        const SizedBox(width: 8),
                        _buildLocationFilterChip('Oja-Oba', setModalState),
                      ],
                    ),
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
                        Navigator.pop(context);
                        _applyFilters();
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

  Widget _buildLocationFilterChip(String location, StateSetter setModalState) {
    return ChoiceChip(
      label: Text(location),
      selected: _selectedLocation == location,
      onSelected: (selected) {
        setModalState(() {
          _selectedLocation = selected ? location : null;
        });
      },
      selectedColor: Colors.blueAccent.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _selectedLocation == location ? Colors.blueAccent : Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _selectedLocation == location
              ? Colors.blueAccent
              : Colors.white24,
        ),
      ),
    );
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
                      '₦${hostel.price}k/year',
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
                                    !(_savedStatus[hostel.id] ?? false);
                                if (_savedStatus[hostel.id]!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Hostel has been saved'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              });
                            },
                            child: Icon(
                              _savedStatus[hostel.id] ?? false
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _savedStatus[hostel.id] ?? false
                                  ? Colors.yellow
                                  : Colors.white70,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Like button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _likedStatus[hostel.id] =
                                    !(_likedStatus[hostel.id] ?? false);
                              });
                            },
                            child: Icon(
                              _likedStatus[hostel.id] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _likedStatus[hostel.id] ?? false
                                  ? Colors.red
                                  : Colors.white70,
                              size: 24,
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
                        hostel.rating.toStringAsFixed(1),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _applyFilters();
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _selectedCategory == label
                  ? Colors.blueAccent.withOpacity(0.2)
                  : const Color(0xFF1D1F33),
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
            child: Icon(icon,
                color: _selectedCategory == label
                    ? Colors.blueAccent
                    : Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: _selectedCategory == label
                  ? Colors.blueAccent
                  : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String city) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = city;
          _applyFilters();
        });
      },
      child: Chip(
        label: Text(city),
        backgroundColor: _selectedLocation == city
            ? Colors.blueAccent.withOpacity(0.2)
            : Colors.transparent,
        labelStyle: TextStyle(
          color: _selectedLocation == city ? Colors.blueAccent : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                _selectedLocation == city ? Colors.blueAccent : Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentListings() {
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
                                      !(_savedStatus[hostel.id] ?? false);
                                  if (_savedStatus[hostel.id]!) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Hostel has been saved'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Icon(
                                _savedStatus[hostel.id] ?? false
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: _savedStatus[hostel.id] ?? false
                                    ? Colors.yellow
                                    : Colors.white70,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Like button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _likedStatus[hostel.id] =
                                      !(_likedStatus[hostel.id] ?? false);
                                });
                              },
                              child: Icon(
                                _likedStatus[hostel.id] ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _likedStatus[hostel.id] ?? false
                                    ? Colors.red
                                    : Colors.white70,
                                size: 24,
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
                          hostel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₦${hostel.price}k',
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
          // Reset current index when returning to home
          if (index == 0) {
            setState(() => _currentIndex = 0);
            return;
          }

          // Navigate to other pages
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExplorePage()),
              ).then((_) => setState(() => _currentIndex = 0));
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedPage()),
              ).then((_) => setState(() => _currentIndex = 0));
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingsPage()),
              ).then((_) => setState(() => _currentIndex = 0));
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ).then((_) => setState(() => _currentIndex = 0));
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostelDetailPage(hostel: hostel),
      ),
    ).then((_) {
      // Reset the current index when returning from details page
      setState(() => _currentIndex = 0);
    });
  }
}
