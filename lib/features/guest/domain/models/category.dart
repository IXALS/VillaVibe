import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Category {
  final String id;
  final String label;
  final String iconName;

  const Category({
    required this.id,
    required this.label,
    required this.iconName,
  });

  IconData get icon {
    switch (iconName) {
      case 'layoutGrid':
        return LucideIcons.layoutGrid;
      case 'waves':
        return LucideIcons.waves;
      case 'mountain':
        return LucideIcons.mountain;
      case 'building2':
        return LucideIcons.building2;
      case 'tent':
        return LucideIcons.tent;
      case 'palmtree':
        return LucideIcons.palmtree;
      case 'snowflake':
        return LucideIcons.snowflake;
      case 'treePine':
        return LucideIcons.treePine;
      default:
        return LucideIcons.layoutGrid;
    }
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      label: data['label'] ?? '',
      iconName: data['iconName'] ?? 'layoutGrid',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'iconName': iconName,
    };
  }
}
