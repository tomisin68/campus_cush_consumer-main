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
  final double rating;
  final bool isAvailable;

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
    required this.rating,
    required this.isAvailable,
  });

  factory Hostel.fromMap(String id, Map<String, dynamic> map) {
    return Hostel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      price: map['price']?.toInt() ?? 0,
      unitsTotal: map['unitsTotal']?.toInt() ?? 0,
      unitsLeft: map['unitsLeft']?.toInt() ?? 0,
      features: List<String>.from(map['features'] ?? []),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rating: map['rating']?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? false,
    );
  }
}
