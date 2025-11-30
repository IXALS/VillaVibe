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
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
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
  final int priceTotal;
  final String dateRangeText;

  final String categoryId;
  final GeoPoint location;

  // New fields for rich data
  final String architectureStyle;
  final double landSize;
  final String vibe;
  final List<String> bedroomNames;
  final String setting;
  final String privacyLevel;
  final List<String> staffServices;
  final List<String> outdoorAmenities;
  final bool isListed;
  final Map<String, int> customPrices;
  final bool isInstantBook;

  Property({
    required this.id,
    required this.hostId,
    this.categoryId = '',
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
    this.priceTotal = 0,
    this.dateRangeText = '',
    this.location = const GeoPoint(-8.409518, 115.188919), // Default to Bali
    
    // Defaults for new fields
    this.architectureStyle = '',
    this.landSize = 0.0,
    this.vibe = '',
    this.bedroomNames = const [],
    this.setting = '',
    this.privacyLevel = '',
    this.staffServices = const [],
    this.outdoorAmenities = const [],
    this.isListed = true,
    this.customPrices = const {},
    this.isInstantBook = true,
  });

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Property(
      id: doc.id,
      hostId: data['hostId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pricePerNight: data['pricePerNight'] ?? 0,
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      specs: PropertySpecs.fromMap(data['specs'] ?? {}),
      amenities: List<String>.from(data['amenities'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
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
      priceTotal: data['priceTotal'] ?? 0,
      dateRangeText: data['dateRangeText'] ?? '',
      location: data['location'] as GeoPoint? ??
          const GeoPoint(-8.409518, 115.188919),
          
      // Map new fields
      architectureStyle: data['architectureStyle'] ?? '',
      landSize: (data['landSize'] as num? ?? 0.0).toDouble(),
      vibe: data['vibe'] ?? '',
      bedroomNames: List<String>.from(data['bedroomNames'] ?? []),
      setting: data['setting'] ?? '',
      privacyLevel: data['privacyLevel'] ?? '',
      staffServices: List<String>.from(data['staffServices'] ?? []),
      outdoorAmenities: List<String>.from(data['outdoorAmenities'] ?? []),
      isListed: (data['isListed'] as bool?) ?? true,
      customPrices: Map<String, int>.from(data['customPrices'] ?? {}),
      isInstantBook: (data['isInstantBook'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'categoryId': categoryId,
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
      'priceTotal': priceTotal,
      'dateRangeText': dateRangeText,
      'location': location,
      
      // Map new fields
      'architectureStyle': architectureStyle,
      'landSize': landSize,
      'vibe': vibe,
      'bedroomNames': bedroomNames,
      'setting': setting,
      'privacyLevel': privacyLevel,
      'staffServices': staffServices,
      'outdoorAmenities': outdoorAmenities,
      'isListed': isListed,
      'customPrices': customPrices,
      'isInstantBook': isInstantBook,
    };
  }

  Property copyWith({
    String? id,
    String? hostId,
    String? categoryId,
    String? name,
    String? description,
    int? pricePerNight,
    String? address,
    String? city,
    PropertySpecs? specs,
    List<String>? amenities,
    List<String>? images,
    double? rating,
    String? hostName,
    String? hostAvatar,
    int? hostYearsHosting,
    int? reviewsCount,
    List<Review>? reviews,
    String? hostWork,
    String? hostDescription,
    String? hostResponseRate,
    String? hostResponseTime,
    String? cancellationPolicy,
    List<String>? houseRules,
    List<String>? safetyItems,
    int? priceTotal,
    String? dateRangeText,
    GeoPoint? location,
    String? architectureStyle,
    double? landSize,
    String? vibe,
    List<String>? bedroomNames,
    String? setting,
    String? privacyLevel,
    List<String>? staffServices,
    List<String>? outdoorAmenities,
    bool? isListed,
    Map<String, int>? customPrices,
    bool? isInstantBook,
  }) {
    return Property(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      address: address ?? this.address,
      city: city ?? this.city,
      specs: specs ?? this.specs,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      hostYearsHosting: hostYearsHosting ?? this.hostYearsHosting,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      reviews: reviews ?? this.reviews,
      hostWork: hostWork ?? this.hostWork,
      hostDescription: hostDescription ?? this.hostDescription,
      hostResponseRate: hostResponseRate ?? this.hostResponseRate,
      hostResponseTime: hostResponseTime ?? this.hostResponseTime,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      houseRules: houseRules ?? this.houseRules,
      safetyItems: safetyItems ?? this.safetyItems,
      priceTotal: priceTotal ?? this.priceTotal,
      dateRangeText: dateRangeText ?? this.dateRangeText,
      location: location ?? this.location,
      architectureStyle: architectureStyle ?? this.architectureStyle,
      landSize: landSize ?? this.landSize,
      vibe: vibe ?? this.vibe,
      bedroomNames: bedroomNames ?? this.bedroomNames,
      setting: setting ?? this.setting,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      staffServices: staffServices ?? this.staffServices,
      outdoorAmenities: outdoorAmenities ?? this.outdoorAmenities,
      isListed: isListed ?? this.isListed,
      customPrices: customPrices ?? this.customPrices,
      isInstantBook: isInstantBook ?? this.isInstantBook,
    );
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
