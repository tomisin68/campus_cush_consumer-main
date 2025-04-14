// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  final List<Booking> upcomingBookings = [
    Booking(
      id: '#CAMPUS123',
      hostelName: 'Urban Haven 🏠',
      location: 'Downtown • 2.4km away',
      date: 'May 15 - 20, 2024',
      price: 245,
      status: 'Confirmed ✅',
      image: 'assets/house1.jpg',
      amenities: [
        '🛏️ Double bed',
        '🚿 Private bath',
        '🛁 Hot shower',
        '📶 Free WiFi'
      ],
    ),
    Booking(
      id: '#CAMPUS456',
      hostelName: 'Mountain View ⛰️',
      location: 'Alpine District • 5.1km away',
      date: 'June 1 - 7, 2024',
      price: 320,
      status: 'Payment Pending 💳',
      image: 'assets/house2.jpg',
      amenities: ['🛏️ Single bed', '🍳 Breakfast', '🏊 Pool', '📶 Free WiFi'],
    ),
  ];

  final List<Booking> completedBookings = [
    Booking(
      id: '#CAMPUS789',
      hostelName: 'Beach Bunker 🏖️',
      location: 'Coastal Area • 8.7km away',
      date: 'Apr 5 - 10, 2024',
      price: 275,
      status: 'Completed 🎉',
      image: 'assets/house3.jpg',
      amenities: [
        '🛏️ Bunk bed',
        '🍳 Breakfast',
        '🏖️ Beachfront',
        '📶 Free WiFi'
      ],
    ),
  ];

  final List<Booking> cancelledBookings = [
    Booking(
      id: '#CAMPUS101',
      hostelName: 'Garden Retreat 🌿',
      location: 'Suburbs • 3.2km away',
      date: 'Mar 20 - 25, 2024',
      price: 190,
      status: 'Cancelled ❌',
      image: 'assets/house5.jpg',
      amenities: [
        '🛏️ Single bed',
        '🌳 Garden view',
        '🚿 Shared bath',
        '📶 Free WiFi'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'My Bookings 📅',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          onPressed: () => _showFilterModal(context),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('Upcoming ✈️', 0),
          _buildTabButton('Completed ✅', 1),
          _buildTabButton('Cancelled ❌', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blueAccent, width: 1.5)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    final bookings = _selectedTab == 0
        ? upcomingBookings
        : _selectedTab == 1
            ? completedBookings
            : cancelledBookings;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/empty_state.svg',
              width: 180,
              color: Colors.white24,
            ),
            const SizedBox(height: 20),
            Text(
              _selectedTab == 0
                  ? 'No upcoming bookings ✈️'
                  : _selectedTab == 1
                      ? 'No completed bookings yet'
                      : 'No cancelled bookings',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to explore page
              },
              child: const Text(
                'Explore Hostels',
                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          // Image & status/price overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  booking.image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: booking.status.contains('✅')
                          ? Colors.greenAccent
                          : booking.status.contains('❌')
                              ? Colors.redAccent
                              : Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${booking.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details & actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.hostelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      booking.id,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      booking.location,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      booking.date,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amenities
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: booking.amenities
                      .map((a) => Chip(
                            label: Text(a),
                            backgroundColor: const Color(0xFF2A2D40),
                            labelStyle: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Actions by tab
                if (_selectedTab == 0) _buildUpcomingActions(booking),
                if (_selectedTab == 1) _buildCompletedActions(),
                if (_selectedTab == 2) _buildCancelledActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActions(Booking booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.message_outlined, size: 18),
            label: const Text('Message Host'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.receipt_outlined, size: 18),
            label: Text(booking.status.contains('Pending')
                ? 'Pay Now'
                : 'View Receipt'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.star_outline, size: 18),
            label: const Text('Leave Review'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.repeat_outlined, size: 18),
            label: const Text('Book Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledActions() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.search_outlined, size: 18),
        label: const Text('Find Similar Hostels'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {},
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1F33),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _FilterModalContent(),
    );
  }
}

class _FilterModalContent extends StatefulWidget {
  const _FilterModalContent();

  @override
  _FilterModalContentState createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<_FilterModalContent> {
  DateTimeRange? _selectedDateRange;
  int _selectedSortOption = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.horizontal_rule_rounded,
              color: Colors.white24,
              size: 36,
            ),
          ),
          const Text(
            'Filter Bookings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Date Range Picker
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 1),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.blueAccent,
                        surface: Color(0xFF1D1F33),
                      ),
                      dialogBackgroundColor: const Color(0xFF0A0E21),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _selectedDateRange = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, y').format(_selectedDateRange!.end)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sort Options
          const Text(
            'Sort By',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('Most Recent', 0),
              _buildSortChip('Price: Low to High', 1),
              _buildSortChip('Price: High to Low', 2),
              _buildSortChip('Check-in Date', 3),
            ],
          ),
          const SizedBox(height: 24),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Apply filters logic here
                Navigator.pop(context);
              },
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, int value) {
    final isSelected = _selectedSortOption == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedSortOption = value),
      selectedColor: Colors.blueAccent.withOpacity(0.2),
      backgroundColor: const Color(0xFF2A2D40),
      labelStyle:
          TextStyle(color: isSelected ? Colors.blueAccent : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side:
            BorderSide(color: isSelected ? Colors.blueAccent : Colors.white24),
      ),
    );
  }
}

class Booking {
  final String id;
  final String hostelName;
  final String location;
  final String date;
  final int price;
  final String status;
  final String image;
  final List<String> amenities;

  Booking({
    required this.id,
    required this.hostelName,
    required this.location,
    required this.date,
    required this.price,
    required this.status,
    required this.image,
    required this.amenities,
  });
}
