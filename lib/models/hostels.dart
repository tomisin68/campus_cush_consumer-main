class Hostel {
  final String name;
  final String agentId;
  final int price;
  final double distance;
  final double rating;
  final int views;
  bool isFavorite;
  final List<String> amenities;
  final String description;

  Hostel({
    required this.name,
    required this.agentId,
    required this.price,
    required this.distance,
    required this.rating,
    required this.views,
    this.isFavorite = false,
    required this.amenities,
    required this.description,
  });
}