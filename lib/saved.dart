// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/models/hostel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_cush_consumer/hostel_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Hostel> _savedHostels = [];
  List<Hostel> _filteredHostels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedHostels();
  }

  Future<void> _loadSavedHostels() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get the user's saved hostel IDs
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final savedHostelIds =
          List<String>.from(userDoc.data()?['savedHostels'] ?? []);

      if (savedHostelIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _savedHostels = [];
          _filteredHostels = [];
        });
        return;
      }

      // Get the hostel documents for the saved IDs
      final query = _firestore
          .collection('hostels')
          .where(FieldPath.documentId, whereIn: savedHostelIds);

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

  Future<void> _toggleSaveHostel(String hostelId, bool isCurrentlySaved) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      if (isCurrentlySaved) {
        // Remove from saved
        await userRef.update({
          'savedHostels': FieldValue.arrayRemove([hostelId])
        });
      } else {
        // Add to saved
        await userRef.update({
          'savedHostels': FieldValue.arrayUnion([hostelId])
        });
      }

      // Reload the saved hostels
      await _loadSavedHostels();
    } catch (e) {
      debugPrint('Error toggling save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update saved hostels'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedHostels.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _savedHostels.length,
                  itemBuilder: (context, index) {
                    final hostel = _savedHostels[index];
                    return _buildSavedHostelCard(hostel);
                  },
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

                // Save Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: () async {
                      await _toggleSaveHostel(hostel.id, true);
                    },
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
              Navigator.pop(context); // Go back to home page
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
