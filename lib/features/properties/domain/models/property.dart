import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String authorName;
  final String authorAvatar;
  final double rating;
  final String content;
  final DateTime date;

  Review({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.content,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'rating': rating,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}

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
  final String hostName;
  final String hostAvatar;
  final int hostYearsHosting;
  final int reviewsCount;
  final List<Review> reviews;
  final String hostWork;
  final String hostDescription;
  final String hostResponseRate;
  final String hostResponseTime;
  final String cancellationPolicy;
  final List<String> houseRules;
  final List<String> safetyItems;

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
    required this.rating,
    required this.hostName,
    required this.hostAvatar,
    required this.hostYearsHosting,
    required this.reviewsCount,
    this.reviews = const [],
    this.hostWork = '',
    this.hostDescription = '',
    this.hostResponseRate = '',
    this.hostResponseTime = '',
    this.cancellationPolicy = '',
    this.houseRules = const [],
    this.safetyItems = const [],
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
      hostName: data['hostName'] ?? '',
      hostAvatar: data['hostAvatar'] ?? '',
      hostYearsHosting: data['hostYearsHosting'] ?? 0,
      reviewsCount: data['reviewsCount'] ?? 0,
      reviews: (data['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromMap(e))
              .toList() ??
          [],
      hostWork: data['hostWork'] ?? '',
      hostDescription: data['hostDescription'] ?? '',
      hostResponseRate: data['hostResponseRate'] ?? '',
      hostResponseTime: data['hostResponseTime'] ?? '',
      cancellationPolicy: data['cancellationPolicy'] ?? '',
      houseRules: List<String>.from(data['houseRules'] ?? []),
      safetyItems: List<String>.from(data['safetyItems'] ?? []),
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
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'hostYearsHosting': hostYearsHosting,
      'reviewsCount': reviewsCount,
      'reviews': reviews.map((e) => e.toMap()).toList(),
      'hostWork': hostWork,
      'hostDescription': hostDescription,
      'hostResponseRate': hostResponseRate,
      'hostResponseTime': hostResponseTime,
      'cancellationPolicy': cancellationPolicy,
      'houseRules': houseRules,
      'safetyItems': safetyItems,
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
