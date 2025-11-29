import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/domain/models/app_user.dart';
import 'package:villavibe/features/favorites/domain/models/wishlist.dart';
part 'favorite_repository.g.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FavoriteRepository(this._firestore, this._ref);

  Future<void> createWishlist(String name, {String? firstVillaId}) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final newWishlist = Wishlist.create(name: name);
    var updatedWishlist = newWishlist;

    if (firstVillaId != null) {
      updatedWishlist = newWishlist.copyWith(villaIds: [firstVillaId]);
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    
    // Update local list
    final updatedWishlists = [updatedWishlist, ...user.wishlists];
    
    // Update savedVillas (sync)
    final updatedSavedVillas = Set<String>.from(user.savedVillas);
    if (firstVillaId != null) {
      updatedSavedVillas.add(firstVillaId);
    }

    await userRef.update({
      'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
      'savedVillas': updatedSavedVillas.toList(),
    });

    _ref.invalidate(currentUserProvider);
  }

  Future<void> addToWishlist(String wishlistId, String villaId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    
    final updatedWishlists = user.wishlists.map((w) {
      if (w.id == wishlistId) {
        if (!w.villaIds.contains(villaId)) {
          return w.copyWith(
            villaIds: [...w.villaIds, villaId],
            updatedAt: DateTime.now(),
          );
        }
      }
      return w;
    }).toList();

    // Sync savedVillas
    final updatedSavedVillas = Set<String>.from(user.savedVillas)..add(villaId);

    await userRef.update({
      'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
      'savedVillas': updatedSavedVillas.toList(),
    });

    _ref.invalidate(currentUserProvider);
  }

  Future<void> removeFromWishlist(String wishlistId, String villaId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    
    var updatedWishlists = user.wishlists.map((w) {
      if (w.id == wishlistId) {
        if (w.villaIds.contains(villaId)) {
          return w.copyWith(
            villaIds: w.villaIds.where((id) => id != villaId).toList(),
            updatedAt: DateTime.now(),
          );
        }
      }
      return w;
    }).toList();

    // Filter out empty wishlists
    updatedWishlists = updatedWishlists.where((w) => w.villaIds.isNotEmpty).toList();

    // Sync savedVillas (rebuild from all wishlists)
    final allVillaIds = updatedWishlists.expand((w) => w.villaIds).toSet();

    await userRef.update({
      'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
      'savedVillas': allVillaIds.toList(),
    });

    _ref.invalidate(currentUserProvider);
  }

  Future<void> moveToWishlist(String targetWishlistId, String villaId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    
    var updatedWishlists = user.wishlists.map((w) {
      if (w.id == targetWishlistId) {
        // Add to target if not present
        if (!w.villaIds.contains(villaId)) {
          return w.copyWith(
            villaIds: [...w.villaIds, villaId],
            updatedAt: DateTime.now(),
          );
        }
        return w;
      } else {
        // Remove from others if present
        if (w.villaIds.contains(villaId)) {
          return w.copyWith(
            villaIds: w.villaIds.where((id) => id != villaId).toList(),
            updatedAt: DateTime.now(),
          );
        }
        return w;
      }
    }).toList();

    // Filter out empty wishlists
    updatedWishlists = updatedWishlists.where((w) => w.villaIds.isNotEmpty).toList();

    // Sync savedVillas
    final allVillaIds = updatedWishlists.expand((w) => w.villaIds).toSet();

    await userRef.update({
      'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
      'savedVillas': allVillaIds.toList(),
    });

    _ref.invalidate(currentUserProvider);
  }

  Future<void> toggleFavorite(String villaId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final isFavorite = user.savedVillas.contains(villaId);
    final userRef = _firestore.collection('users').doc(user.uid);

    if (isFavorite) {
      // Remove from ALL wishlists
      var updatedWishlists = user.wishlists.map((w) {
        if (w.villaIds.contains(villaId)) {
          return w.copyWith(
            villaIds: w.villaIds.where((id) => id != villaId).toList(),
            updatedAt: DateTime.now(),
          );
        }
        return w;
      }).toList();

      // Filter out empty wishlists (User request: remove empty folders)
      updatedWishlists = updatedWishlists.where((w) => w.villaIds.isNotEmpty).toList();

      final updatedSavedVillas = Set<String>.from(user.savedVillas)..remove(villaId);

      await userRef.update({
        'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
        'savedVillas': updatedSavedVillas.toList(),
      });
    } else {
      // Add to MOST RECENT wishlist (first one)
      if (user.wishlists.isNotEmpty) {
        final targetWishlist = user.wishlists.first;
        await addToWishlist(targetWishlist.id, villaId);
      } else {
        // Should be handled by UI. Do not auto-create.
        // If we reach here, it means UI thought we had wishlists but we don't.
        // Just return or log error.
        print('Error: toggleFavorite called but no wishlists exist.');
        return;
      }
    }

    _ref.invalidate(currentUserProvider);
  }

  Future<void> deleteWishlist(String wishlistId) async {
    final user = await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    // Filter out the wishlist to delete
    final updatedWishlists = user.wishlists.where((w) => w.id != wishlistId).toList();

    // Also remove any villas that were ONLY in this wishlist?
    // For now, let's keep savedVillas as is, or we should sync it?
    // If we delete a wishlist, the villas in it are no longer "saved" in that list.
    // But they might be in other lists.
    // Since savedVillas is an aggregate, we should rebuild it.
    
    final allVillaIds = updatedWishlists.expand((w) => w.villaIds).toSet();
    
    await userRef.update({
      'wishlists': updatedWishlists.map((w) => w.toMap()).toList(),
      'savedVillas': allVillaIds.toList(),
    });

    _ref.invalidate(currentUserProvider);
  }
}

@riverpod
FavoriteRepository favoriteRepository(FavoriteRepositoryRef ref) {
  return FavoriteRepository(FirebaseFirestore.instance, ref);
}
