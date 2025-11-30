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
      location: property.location,
      
      // Rich Data Fields
      architectureStyle: property.architectureStyle,
      landSize: property.landSize,
      vibe: property.vibe,
      bedroomNames: property.bedroomNames,
      setting: property.setting,
      privacyLevel: property.privacyLevel,
      staffServices: property.staffServices,
      outdoorAmenities: property.outdoorAmenities,
      isInstantBook: property.isInstantBook,
    );
    await docRef.set(newProperty.toMap());
  }

  Future<void> updateProperty(Property property) async {
    if (property.id.isEmpty) return;
    await _firestore.collection('properties').doc(property.id).update(property.toMap());
  }

  Future<void> deleteProperty(String id) async {
    if (id.isEmpty) return;
    await _firestore.collection('properties').doc(id).delete();
  }

  Future<void> updatePropertyPrice(String propertyId, int newPrice) async {
    if (propertyId.isEmpty) return;
    await _firestore.collection('properties').doc(propertyId).update({
      'pricePerNight': newPrice,
    });
  }

  Future<void> setCustomPrice(String propertyId, DateTime date, int price) async {
    if (propertyId.isEmpty) return;
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _firestore.collection('properties').doc(propertyId).update({
      'customPrices.$dateStr': price,
    });
  }

  Future<void> updateInstantBook(String propertyId, bool isInstantBook) async {
    if (propertyId.isEmpty) return;
    await _firestore.collection('properties').doc(propertyId).update({
      'isInstantBook': isInstantBook,
    });
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

  Future<void> seedProperties(List<Property> properties) async {
    final batch = _firestore.batch();
    
    for (var property in properties) {
      final docRef = _firestore.collection('properties').doc();
      // Create a copy with the new ID
      final newProperty = Property(
        id: docRef.id,
        hostId: property.hostId,
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
        categoryId: property.categoryId,
        architectureStyle: property.architectureStyle,
        landSize: property.landSize,
        vibe: property.vibe,
        bedroomNames: property.bedroomNames,
        setting: property.setting,
        privacyLevel: property.privacyLevel,
        staffServices: property.staffServices,
        outdoorAmenities: property.outdoorAmenities,
        location: property.location,
        // Ensure all fields are copied, including those not explicitly listed in the snippet
        reviews: property.reviews,
        hostWork: property.hostWork,
        hostDescription: property.hostDescription,
        hostResponseRate: property.hostResponseRate,
        hostResponseTime: property.hostResponseTime,
        cancellationPolicy: property.cancellationPolicy,
        houseRules: property.houseRules,
        safetyItems: property.safetyItems,
        isInstantBook: property.isInstantBook,
      );
      
      batch.set(docRef, newProperty.toMap());
    }
    
    await batch.commit();
  }
  
  Future<Property?> getProperty(String id) async {
    final doc = await _firestore.collection('properties').doc(id).get();
    if (!doc.exists) return null;
    return Property.fromFirestore(doc);
  }

  Future<bool> hasProperties(String hostId) async {
    final snapshot = await _firestore
        .collection('properties')
        .where('hostId', isEqualTo: hostId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
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
