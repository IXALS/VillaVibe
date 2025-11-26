import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/property.dart';

part 'property_repository.g.dart';

class PropertyRepository {
  final FirebaseFirestore _firestore;

  PropertyRepository(this._firestore);

  Future<void> addProperty(Property property) async {
    // If id is empty or new, we might want to let Firestore generate it,
    // but the model expects an ID. Usually we create a doc ref first.
    final docRef = _firestore.collection('properties').doc();
    final newProperty = Property(
      id: docRef.id,
      hostId: property.hostId,
      categoryId: property.categoryId,
      name: property.name,
      description: property.description,
      pricePerNight: property.pricePerNight,
      address: property.address,
      city: property.city,
      specs: property.specs,
      amenities: property.amenities,
      images: property.images,
      rating: property.rating,
      hostName: property.hostName,
      hostAvatar: property.hostAvatar,
      hostYearsHosting: property.hostYearsHosting,
      reviewsCount: property.reviewsCount,
      reviews: property.reviews,
      hostWork: property.hostWork,
      hostDescription: property.hostDescription,
      hostResponseRate: property.hostResponseRate,
      hostResponseTime: property.hostResponseTime,
      cancellationPolicy: property.cancellationPolicy,
      houseRules: property.houseRules,
      safetyItems: property.safetyItems,
    );
    await docRef.set(newProperty.toMap());
  }

  Stream<List<Property>> getPropertiesByHost(String hostId) {
    return _firestore
        .collection('properties')
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList());
  }

  Stream<List<Property>> getAllProperties() {
    return _firestore.collection('properties').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList());
  }

  Future<Property?> getProperty(String id) async {
    final doc = await _firestore.collection('properties').doc(id).get();
    if (!doc.exists) return null;
    return Property.fromFirestore(doc);
  }
}

@riverpod
PropertyRepository propertyRepository(PropertyRepositoryRef ref) {
  return PropertyRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Property>> hostProperties(HostPropertiesRef ref, String hostId) {
  return ref.watch(propertyRepositoryProvider).getPropertiesByHost(hostId);
}

@riverpod
Stream<List<Property>> allProperties(AllPropertiesRef ref) {
  return ref.watch(propertyRepositoryProvider).getAllProperties();
}

@riverpod
Future<Property?> property(PropertyRef ref, String id) {
  return ref.watch(propertyRepositoryProvider).getProperty(id);
}
