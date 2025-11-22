import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/domain/models/app_user.dart';
part 'favorite_repository.g.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FavoriteRepository(this._firestore, this._ref);

  Future<void> toggleFavorite(String villaId) async {
    final user = await _ref.read(currentUserProvider.future);

    if (user == null) return; // User harus login dulu

    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      if (user.savedVillas.contains(villaId)) {
        // Hapus dari wishlist
        await userRef.update({
          'savedVillas': FieldValue.arrayRemove([villaId])
        });
      } else {
        // Tambah ke wishlist
        await userRef.update({
          'savedVillas': FieldValue.arrayUnion([villaId])
        });
      }

      // Refresh user data to update UI
      _ref.invalidate(currentUserProvider);
    } catch (e, stack) {
      print('Error toggling favorite for villaId $villaId: $e');
      print(stack);
    }
  }
}

@riverpod
FavoriteRepository favoriteRepository(FavoriteRepositoryRef ref) {
  return FavoriteRepository(FirebaseFirestore.instance, ref);
}
