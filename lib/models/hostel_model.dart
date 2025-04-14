import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String agentId;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

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
    required this.agentId,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.createdAt,
  });

  factory Hostel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hostel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      price: data['price']?.toInt() ?? 0,
      unitsTotal: data['unitsTotal']?.toInt() ?? 0,
      unitsLeft: data['unitsLeft']?.toInt() ?? 0,
      features: List<String>.from(data['features'] ?? []),
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      agentId: data['agentId'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount']?.toInt() ?? 0,
      isAvailable: data['isAvailable'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
