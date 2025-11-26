import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:villavibe/features/guest/data/mock_data.dart';
import 'package:villavibe/features/guest/domain/models/category.dart';

class SeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedCategories() async {
    final collection = _firestore.collection('categories');
    
    // Cleanup existing categories to avoid duplicates/mismatches
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Always ensure "All" category exists or logic handles it. 
    // In our UI, "All" is a special case, so we might not need to seed it if we handle it in UI.
    // But let's seed the others.
    
    // Actually, let's seed "All" too so it appears in the list, 
    // and we'll handle the selection logic in UI (which I already did).
    final allCategory = Category(id: 'all', label: 'All', iconName: 'layoutGrid');
    
    try {
       await collection.doc(allCategory.id).set(allCategory.toMap());
    } catch (e) {
      print('Error seeding All category: $e');
    }

    for (final category in mockCategories) {
      try {
        await collection.doc(category.id).set(category.toMap());
        print('Seeded category: ${category.label}');
      } catch (e) {
        print('Error seeding category ${category.label}: $e');
      }
    }
  }

  Future<void> seedProperties() async {
    final collection = _firestore.collection('properties');

    // Cleanup existing properties to ensure clean state
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    for (final property in mockProperties) {
      try {
        await collection.doc(property.id).set(property.toMap());
        print('Seeded property: ${property.id}');
      } catch (e) {
        print('Error seeding property ${property.id}: $e');
      }
    }
  }
}
