import 'package:cloud_firestore/cloud_firestore.dart';

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
