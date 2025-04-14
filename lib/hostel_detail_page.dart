import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/models/hostel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HostelDetailPage extends StatefulWidget {
  final Hostel hostel;

  const HostelDetailPage({Key? key, required this.hostel}) : super(key: key);

  @override
  State<HostelDetailPage> createState() => _HostelDetailPageState();
}

class _HostelDetailPageState extends State<HostelDetailPage> {
  int _currentImageIndex = 0;
  Agent? _agent;
  bool _isLoadingAgent = true;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
    _loadReviews();
  }

  Future<void> _loadAgentData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.hostel.agentId)
          .get();

      if (doc.exists) {
        setState(() {
          _agent = Agent.fromFirestore(doc);
          _isLoadingAgent = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading agent: $e');
      setState(() => _isLoadingAgent = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('hostels')
          .doc(widget.hostel.id)
          .collection('reviews')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _reviews = query.docs.map((doc) => doc.data()).toList();
        _isLoadingReviews = false;
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  _buildImageSlider(),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.hostel.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareHostel,
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHostelHeader(),
                  const SizedBox(height: 16),
                  _buildHostelDetails(),
                  const SizedBox(height: 24),
                  _buildAgentSection(),
                  const SizedBox(height: 24),
                  _buildFeaturesSection(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
                  const SizedBox(height: 24),
                  _buildBookingButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return CarouselSlider.builder(
      itemCount: widget.hostel.imageUrls.length,
      itemBuilder: (context, index, realIndex) {
        return CachedNetworkImage(
          imageUrl: widget.hostel.imageUrls[index],
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.image_not_supported, color: Colors.white),
          ),
        );
      },
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        onPageChanged: (index, reason) {
          setState(() => _currentImageIndex = index);
        },
      ),
    );
  }

  Widget _buildHostelHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hostel.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 4),
            Text(
              widget.hostel.location,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              widget.hostel.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (${widget.hostel.reviewCount})',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '₦${widget.hostel.price.toStringAsFixed(0)} / year',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHostelDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(Icons.king_bed, '${widget.hostel.unitsLeft} Left'),
          _buildDetailItem(Icons.type_specimen, widget.hostel.type),
          _buildDetailItem(Icons.check_circle, 'Verified'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _isLoadingAgent
              ? const Center(child: CircularProgressIndicator())
              : _agent != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _agent!.profilePicture.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  _agent!.profilePicture)
                              : null,
                          child: _agent!.profilePicture.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _agent!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _agent!.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_agent!.verified)
                                    Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        const Icon(Icons.verified,
                                            color: Colors.blueAccent, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.chat, color: Colors.blueAccent),
                          onPressed: _contactAgent,
                        ),
                      ],
                    )
                  : const Text(
                      'Agent information not available',
                      style: TextStyle(color: Colors.white70),
                    ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.hostel.features
              .map((feature) => Chip(
                    label: Text(feature),
                    backgroundColor: const Color(0xFF1D1F33),
                    labelStyle: const TextStyle(color: Colors.white),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.hostel.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _isLoadingReviews
            ? const Center(child: CircularProgressIndicator())
            : _reviews.isEmpty
                ? const Text(
                    'No reviews yet',
                    style: TextStyle(color: Colors.white70),
                  )
                : Column(
                    children: _reviews
                        .map((review) => _buildReviewItem(review))
                        .toList(),
                  ),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(review['userName'][0]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        review['rating'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatDate(review['date']),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _bookHostel,
        child: const Text(
          'Book Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareHostel() {
    // Implement share functionality
  }

  void _toggleFavorite() {
    // Implement favorite functionality
  }

  void _contactAgent() {
    // Implement contact agent functionality
  }

  void _bookHostel() {
    // Implement booking functionality
  }
}

class Agent {
  final String id;
  final String name;
  final String phone;
  final String profilePicture;
  final double rating;
  final bool verified;

  Agent({
    required this.id,
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.rating,
    required this.verified,
  });

  factory Agent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Agent(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      verified: data['verified'] ?? false,
    );
  }
}
