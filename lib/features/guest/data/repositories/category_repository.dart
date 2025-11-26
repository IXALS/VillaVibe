import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/category.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  Stream<List<Category>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      final categories =
          snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      
      // Sort: "All" first, then alphabetical or by a specific order field if we had one.
      // For now, let's just ensure "All" is at the top if it exists.
      categories.sort((a, b) {
        if (a.label == 'All') return -1;
        if (b.label == 'All') return 1;
        return a.label.compareTo(b.label);
      });
      
      return categories;
    });
  }

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toMap());
  }
}

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Category>> categories(CategoriesRef ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
}
