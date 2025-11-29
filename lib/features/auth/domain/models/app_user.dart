import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:villavibe/features/favorites/domain/models/wishlist.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isHost;
  final List<String> savedVillas; // Deprecated: Use wishlists instead
  final List<Wishlist> wishlists;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.isHost = false,
    this.savedVillas = const [],
    this.wishlists = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isHost: data['isHost'] ?? false,
      savedVillas: List<String>.from(data['savedVillas'] ?? []),
      wishlists: (data['wishlists'] as List<dynamic>?)
              ?.map((e) => Wishlist.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isHost': isHost,
      'savedVillas': savedVillas,
      'wishlists': wishlists.map((e) => e.toMap()).toList(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isHost,
    List<String>? savedVillas,
    List<Wishlist>? wishlists,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isHost: isHost ?? this.isHost,
      savedVillas: savedVillas ?? this.savedVillas,
      wishlists: wishlists ?? this.wishlists,
    );
  }
}
