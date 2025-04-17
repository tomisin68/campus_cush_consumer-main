import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/models/hostel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_cush_consumer/hostel_detail_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Hostel> _savedHostels = [];
  bool _isLoading = true;
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSavedHostels();
  }

  Future<void> _loadSavedHostels() async {
    try {
      // In a real app, you would query hostels that the user has saved
      // For now, we'll use a dummy query - replace with your actual saved hostels logic
      final query = _firestore
          .collection('hostels')
          .where('isAvailable', isEqualTo: true)
          .limit(5);

      final snapshot = await query.get();
      final hostels = _parseHostelDocuments(snapshot.docs);

      setState(() {
        _savedHostels = hostels;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading saved hostels: $e');
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Saved Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _savedHostels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _savedHostels.length,
                        itemBuilder: (context, index) {
                          final hostel = _savedHostels[index];
                          return _buildSavedHostelCard(hostel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Saved Hostels',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Implement search functionality
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Private', 'Shared', 'Studio', 'Near Campus'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: _currentFilter == filter
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                ),
              ),
              selected: _currentFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = selected ? filter : 'All';
                  // Apply filter logic here
                });
              },
              selectedColor: Colors.blueAccent,
              backgroundColor: const Color(0xFF1D1F33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedHostelCard(Hostel hostel) {
    return GestureDetector(
      onTap: () => _navigateToHostelDetails(hostel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                // Hostel Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: hostel.imageUrls.isNotEmpty
                      ? Image.network(
                          hostel.imageUrls[0],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
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
                              height: 180,
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white),
                        ),
                ),

                // Price Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
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

            // Hostel Details
            Padding(
              padding: const EdgeInsets.all(16),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            hostel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        hostel.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hostel.features.contains('WiFi'))
                        _buildFeatureChip(Icons.wifi, 'WiFi'),
                      if (hostel.features.contains('Kitchen') ||
                          hostel.features.contains('Shared Kitchen'))
                        _buildFeatureChip(Icons.kitchen, 'Kitchen'),
                      if (hostel.features.contains('Laundry'))
                        _buildFeatureChip(
                            Icons.local_laundry_service, 'Laundry'),
                      if (hostel.features.contains('Air Conditioning'))
                        _buildFeatureChip(Icons.ac_unit, 'AC'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _navigateToHostelDetails(hostel);
                          },
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Book now action
                          },
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Saved Hostels',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Save hostels you like by tapping the bookmark icon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Navigate to explore page
            },
            child: const Text(
              'Explore Hostels',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    );
  }
}
