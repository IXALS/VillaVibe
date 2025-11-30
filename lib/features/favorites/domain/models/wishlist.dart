import 'package:uuid/uuid.dart';

class Wishlist {
  final String id;
  final String name;
  final List<String> villaIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wishlist({
    required this.id,
    required this.name,
    this.villaIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wishlist.create({required String name}) {
    final now = DateTime.now();
    return Wishlist(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      villaIds: List<String>.from(map['villaIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'villaIds': villaIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Wishlist copyWith({
    String? id,
    String? name,
    List<String>? villaIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
      id: id ?? this.id,
      name: name ?? this.name,
      villaIds: villaIds ?? this.villaIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
