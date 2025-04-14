import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _saveController;
  late AnimationController _likeController;

  String _selectedCategory = 'All';
  int _selectedFilterIndex = 0;
  bool _showMapView = false;

  // Sample data
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.all_inclusive, 'label': 'All'},
    {'icon': Icons.home_work, 'label': 'Hostels'},
    {'icon': Icons.apartment, 'label': 'Apartments'},
    {'icon': Icons.house, 'label': 'Houses'},
    {'icon': Icons.people, 'label': 'Shared'},
    {'icon': Icons.star, 'label': 'Premium'},
  ];

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Recommended', 'icon': Icons.thumb_up},
    {'label': 'Price: Low to High', 'icon': Icons.attach_money},
    {'label': 'Price: High to Low', 'icon': Icons.money_off},
    {'label': 'Rating', 'icon': Icons.star},
    {'label': 'Distance', 'icon': Icons.location_on},
  ];

  final List<Map<String, dynamic>> _properties = [
    {
      'id': 'p1',
      'title': 'Urban Haven Hostel',
      'location': 'Downtown • 0.5mi from campus',
      'price': 45,
      'rating': 4.8,
      'type': 'Private Room',
      'image': 'house1',
      'saved': false,
      'liked': false,
      'amenities': ['wifi', 'kitchen', 'laundry'],
    },
    {
      'id': 'p2',
      'title': 'Mountain View Apartments',
      'location': 'Alpine District • 1.2mi from campus',
      'price': 65,
      'rating': 4.9,
      'type': 'Shared Room',
      'image': 'house2',
      'saved': true,
      'liked': true,
      'amenities': ['wifi', 'breakfast', 'gym'],
    },
    {
      'id': 'p3',
      'title': 'Beach Bunker Residence',
      'location': 'Coastal Area • 2.1mi from campus',
      'price': 55,
      'rating': 4.7,
      'type': 'Studio',
      'image': 'house3',
      'saved': false,
      'liked': false,
      'amenities': ['wifi', 'pool', 'parking'],
    },
    {
      'id': 'p4',
      'title': 'Garden Retreat House',
      'location': 'Suburbs • 1.8mi from campus',
      'price': 39,
      'rating': 4.5,
      'type': 'Private Room',
      'image': 'house5',
      'saved': false,
      'liked': false,
      'amenities': ['wifi', 'garden', 'kitchen'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(vsync: this);
    _likeController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _saveController.dispose();
    _likeController.dispose();
    _searchController.dispose();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: primaryColor,
              statusBarIconBrightness: Brightness.light,
            ),
            expandedHeight: _showMapView ? 0 : 180,
            floating: false,
            pinned: true,
            flexibleSpace: _showMapView
                ? null
                : FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: primaryColor,
                      padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                      child: _buildSearchSection(primaryColor, textColor),
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (!_showMapView) ...[
                    const SizedBox(height: 8),
                    _buildCategorySection(textColor),
                    const SizedBox(height: 16),
                    _buildFilterSection(textColor),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          _showMapView
              ? SliverFillRemaining(
                  child: _buildMapPlaceholder(primaryColor, textColor),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = _properties[index];
                      return _buildPropertyCard(
                        property,
                        textColor,
                        cardColor!,
                        index == _properties.length - 1,
                      );
                    },
                    childCount: _properties.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          setState(() {
            _showMapView = !_showMapView;
          });
        },
        child: Icon(
          _showMapView ? Icons.list : Icons.map,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchSection(Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search hostels, apartments...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.grey),
                  onPressed: () => _showAdvancedFilters(),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: GoogleFonts.roboto(color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilter('Near Me', Icons.location_on),
                const SizedBox(width: 8),
                _buildQuickFilter('Under \$50', Icons.attach_money),
                const SizedBox(width: 8),
                _buildQuickFilter('Verified Only', Icons.verified),
                const SizedBox(width: 8),
                _buildQuickFilter('Available Now', Icons.calendar_today),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildCategorySection(Color textColor) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['label'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['label'];
              });
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0A0E21).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0A0E21)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected
                          ? const Color(0xFF0A0E21)
                          : Colors.grey[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['label'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF0A0E21) : textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(Color textColor) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding:
                EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF0A0E21),
                  ),
                  const SizedBox(width: 4),
                  Text(filter['label']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex = selected ? index : 0;
                });
              },
              selectedColor: const Color(0xFF0A0E21),
              labelStyle: GoogleFonts.roboto(
                color: isSelected ? Colors.white : textColor,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
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

  Widget _buildPropertyCard(
    Map<String, dynamic> property,
    Color textColor,
    Color cardColor,
    bool isLast,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 32 : 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to property details
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Property Image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      'assets/${property['image']}.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Price Tag
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E21).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${property['price']}/night',
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
                          property['saved'] = !property['saved'];
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
                          animate: property['saved'],
                          onLoaded: (composition) {
                            _saveController
                              ..duration = composition.duration
                              ..forward(from: 0);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Like Button
                  Positioned(
                    top: 60,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          property['liked'] = !property['liked'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Lottie.asset(
                          'assets/love.json',
                          controller: _likeController,
                          animate: property['liked'],
                          onLoaded: (composition) {
                            _likeController
                              ..duration = composition.duration
                              ..forward(from: 0);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Property Details
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
                            property['title'],
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
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              property['rating'].toString(),
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
                          property['location'],
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                        if (property['amenities'].contains('wifi'))
                          _buildAmenityChip(Icons.wifi, 'WiFi'),
                        if (property['amenities'].contains('kitchen'))
                          _buildAmenityChip(Icons.kitchen, 'Kitchen'),
                        if (property['amenities'].contains('laundry'))
                          _buildAmenityChip(
                              Icons.local_laundry_service, 'Laundry'),
                        if (property['amenities'].contains('breakfast'))
                          _buildAmenityChip(Icons.free_breakfast, 'Breakfast'),
                        if (property['amenities'].contains('gym'))
                          _buildAmenityChip(Icons.fitness_center, 'Gym'),
                        if (property['amenities'].contains('pool'))
                          _buildAmenityChip(Icons.pool, 'Pool'),
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
                              side: BorderSide(
                                  color: Colors.grey.withOpacity(0.3)),
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
                              backgroundColor: const Color(0x0ff00e21),
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

  Widget _buildMapPlaceholder(Color primaryColor, Color textColor) {
    return Stack(
      children: [
        // This would be replaced with your actual map widget
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 60, color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Map View',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Properties would be displayed here',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search bar overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search on map...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showAdvancedFilters(),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: GoogleFonts.roboto(color: Colors.black),
            ),
          ),
        ),

        // Bottom sheet with property previews
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildMapPropertyCard(property, textColor),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPropertyCard(Map<String, dynamic> property, Color textColor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to property details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/${property['image']}.jpg',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        property['rating'].toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${property['price']}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double priceRange = 150;
            RangeValues distanceRange = const RangeValues(0, 5);
            bool wifi = false;
            bool kitchen = false;
            bool laundry = false;
            bool verifiedOnly = true;

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
                  const SizedBox(height: 16),
                  Text(
                    'Advanced Filters',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            onChanged: (value) {
                              setModalState(() {
                                priceRange = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Distance from Campus (miles)',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          RangeSlider(
                            values: distanceRange,
                            min: 0,
                            max: 10,
                            divisions: 10,
                            labels: RangeLabels(
                              '${distanceRange.start.round()} mi',
                              '${distanceRange.end.round()} mi',
                            ),
                            activeColor: const Color(0xFF0A0E21),
                            onChanged: (values) {
                              setModalState(() {
                                distanceRange = values;
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
                              _buildFilterChip('WiFi', Icons.wifi, wifi,
                                  (value) {
                                setModalState(() => wifi = value);
                              }),
                              _buildFilterChip(
                                  'Kitchen', Icons.kitchen, kitchen, (value) {
                                setModalState(() => kitchen = value);
                              }),
                              _buildFilterChip(
                                  'Laundry',
                                  Icons.local_laundry_service,
                                  laundry, (value) {
                                setModalState(() => laundry = value);
                              }),
                              _buildFilterChip(
                                  'Verified Only', Icons.verified, verifiedOnly,
                                  (value) {
                                setModalState(() => verifiedOnly = value);
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
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
                            'Show Results',
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
      String label, IconData icon, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon),
      selected: isSelected,
      onSelected: onSelected,
    );
  }
}
