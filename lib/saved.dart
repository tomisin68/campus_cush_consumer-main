import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with TickerProviderStateMixin {
  // Sample saved items data
  final List<Map<String, dynamic>> _savedItems = [
    {
      'id': 'house1',
      'image': 'house1',
      'name': 'Urban Haven',
      'location': 'Downtown',
      'rating': 4.8,
      'price': 45,
      'saved': true,
      'type': 'Private Room',
      'distance': '0.5 mi from campus',
      'amenities': ['wifi', 'kitchen', 'laundry'],
    },
    {
      'id': 'house2',
      'image': 'house2',
      'name': 'Mountain View',
      'location': 'Alpine District',
      'rating': 4.9,
      'price': 65,
      'saved': true,
      'type': 'Shared Room',
      'distance': '1.2 mi from campus',
      'amenities': ['wifi', 'breakfast', 'gym'],
    },
    {
      'id': 'house3',
      'image': 'house3',
      'name': 'Beach Bunker',
      'location': 'Coastal Area',
      'rating': 4.7,
      'price': 55,
      'saved': true,
      'type': 'Studio',
      'distance': '2.1 mi from campus',
      'amenities': ['wifi', 'pool', 'parking'],
    },
  ];

  late AnimationController _saveController;
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _saveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFF0A0E21);
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      appBar: _buildAppBar(textColor, primaryColor),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(textColor),

          // Saved Items List
          Expanded(
            child: _savedItems.isEmpty
                ? _buildEmptyState(textColor)
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _savedItems.length,
                    itemBuilder: (context, index) {
                      final item = _savedItems[index];
                      return _buildSavedItemCard(item, textColor, cardColor!);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color textColor, Color primaryColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Saved Items',
        style: GoogleFonts.roboto(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: textColor),
          onPressed: () {
            // Implement search functionality
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: textColor),
          onPressed: () {
            _showFilterBottomSheet();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips(Color textColor) {
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
              label: Text(filter),
              selected: _currentFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = selected ? filter : 'All';
                });
              },
              selectedColor: const Color(0xFF0A0E21).withOpacity(0.2),
              labelStyle: GoogleFonts.roboto(
                color: _currentFilter == filter
                    ? const Color(0xFF0A0E21)
                    : textColor,
                fontWeight: _currentFilter == filter
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _currentFilter == filter
                      ? const Color(0xFF0A0E21)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedItemCard(
      Map<String, dynamic> item, Color textColor, Color cardColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to item details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Item Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/${item['image']}.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                      color: const Color(0xFF0A0E21).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${item['price']}/night',
                      style: GoogleFonts.roboto(
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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        item['saved'] = !item['saved'];
                        if (!item['saved']) {
                          _savedItems.removeWhere((i) => i['id'] == item['id']);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.asset(
                        'assets/saved.json',
                        controller: _saveController,
                        animate: item['saved'],
                        onLoaded: (composition) {
                          _saveController
                            ..duration = composition.duration
                            ..forward(from: 0);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Item Details
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
                          item['name'],
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
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
                            item['rating'].toString(),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['location'],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E21).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['type'],
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: const Color(0xFF0A0E21),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E21).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['distance'],
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: const Color(0xFF0A0E21),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Amenities
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmenityChip(Icons.wifi, 'WiFi'),
                      _buildAmenityChip(Icons.local_dining, 'Kitchen'),
                      _buildAmenityChip(Icons.local_laundry_service, 'Laundry'),
                      if (item['amenities'].contains('pool'))
                        _buildAmenityChip(Icons.pool, 'Pool'),
                      if (item['amenities'].contains('gym'))
                        _buildAmenityChip(Icons.fitness_center, 'Gym'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // View details action
                          },
                          child: Text(
                            'View Details',
                            style: GoogleFonts.roboto(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A0E21),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Book now action
                          },
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.roboto(
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

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0A0E21)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: const Color(0xFF0A0E21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/empty_saved.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'No Saved Items Yet',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the heart icon on listings to save them here for easy access later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A0E21),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Navigate to explore page
            },
            child: Text(
              'Explore Listings',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filter Saved Items',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Price Range (per night)',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: priceRange,
                    min: 0,
                    max: 500,
                    divisions: 10,
                    label: '\$${priceRange.round()}',
                    activeColor: const Color(0xFF0A0E21),
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      setModalState(() {
                        priceRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Amenities',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('WiFi', Icons.wifi, wifi, (value) {
                        setModalState(() => wifi = value);
                      }),
                      _buildFilterChip(
                          'Breakfast', Icons.free_breakfast, breakfast,
                          (value) {
                        setModalState(() => breakfast = value);
                      }),
                      _buildFilterChip(
                          'Private Bath', Icons.bathtub, privateBathroom,
                          (value) {
                        setModalState(() => privateBathroom = value);
                      }),
                      _buildFilterChip(
                          'Parking', Icons.local_parking, false, (value) {}),
                      _buildFilterChip(
                          'Gym', Icons.fitness_center, false, (value) {}),
                      _buildFilterChip('Pool', Icons.pool, false, (value) {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Reset',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A0E21),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Apply filters
                          },
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
      String label, IconData icon, bool selected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF0A0E21).withOpacity(0.2),
      labelStyle: GoogleFonts.roboto(
        color: selected ? const Color(0xFF0A0E21) : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              selected ? const Color(0xFF0A0E21) : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
