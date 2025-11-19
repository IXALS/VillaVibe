import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String hostId;
  final String name;
  final String description;
  final int pricePerNight;
  final String address;
  final String city;
  final PropertySpecs specs;
  final List<String> amenities;
  final List<String> images;
  final double rating;

  Property({
    required this.id,
    required this.hostId,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.address,
    required this.city,
    required this.specs,
    required this.amenities,
    required this.images,
    this.rating = 0.0,
  });

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Property(
      id: doc.id,
      hostId: data['hostId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pricePerNight: data['pricePerNight'] ?? 0,
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      specs: PropertySpecs.fromMap(data['specs'] ?? {}),
      amenities: List<String>.from(data['amenities'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'name': name,
      'description': description,
      'pricePerNight': pricePerNight,
      'address': address,
      'city': city,
      'specs': specs.toMap(),
      'amenities': amenities,
      'images': images,
      'rating': rating,
    };
  }
}

class PropertySpecs {
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;

  PropertySpecs({
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
  });

  factory PropertySpecs.fromMap(Map<String, dynamic> map) {
    return PropertySpecs(
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      maxGuests: map['maxGuests'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'maxGuests': maxGuests,
    };
  }
}
