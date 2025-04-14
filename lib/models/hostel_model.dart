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
  final String
      agentId; // Now properly handles both string IDs and DocumentReferences
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

  factory Hostel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc
        .data()!; // Using non-null assertion since we check exists before calling

    // Improved agentId handling
    final agentId = switch (data['agentId']) {
      DocumentReference<Object?>(id: final id) =>
        id, // If it's a DocumentReference
      String() => data['agentId'], // If it's already a string
      _ => '', // Fallback for null or other types
    };

    // Safer list conversion with type checking
    List<String> safeListConvert(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return [];
    }

    return Hostel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      type: data['type'] as String? ?? '',
      location: data['location'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      unitsTotal: (data['unitsTotal'] as num?)?.toInt() ?? 0,
      unitsLeft: (data['unitsLeft'] as num?)?.toInt() ?? 0,
      features: safeListConvert(data['features']),
      description: data['description'] as String? ?? '',
      imageUrls: safeListConvert(data['imageUrls']),
      agentId: agentId,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Optional: Add toMap() for saving data back to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'price': price,
      'unitsTotal': unitsTotal,
      'unitsLeft': unitsLeft,
      'features': features,
      'description': description,
      'imageUrls': imageUrls,
      'agentId': FirebaseFirestore.instance.doc('agents/$agentId'),
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
