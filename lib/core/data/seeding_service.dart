import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:villavibe/features/guest/data/mock_data.dart';

class SeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedProperties() async {
    final collection = _firestore.collection('properties');

    for (final property in mockProperties) {
      try {
        // Check if property already exists
        final doc = await collection.doc(property.id).get();
        if (!doc.exists) {
          await collection.doc(property.id).set(property.toMap());
          print('Seeded property: ${property.id}');
        } else {
          // Optional: Update existing property to match mock data
          await collection.doc(property.id).update(property.toMap());
          print('Updated property: ${property.id}');
        }
      } catch (e) {
        print('Error seeding property ${property.id}: $e');
      }
    }
  }
}
