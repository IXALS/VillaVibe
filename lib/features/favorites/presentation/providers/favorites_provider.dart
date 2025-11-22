import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

part 'favorites_provider.g.dart';

@riverpod
Future<List<Property>> favoriteProperties(FavoritePropertiesRef ref) async {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null || user.savedVillas.isEmpty) {
    return [];
  }

  final allProperties = await ref.watch(allPropertiesProvider.future);

  // Filter properties that are in the user's savedVillas list
  return allProperties
      .where((property) => user.savedVillas.contains(property.id))
      .toList();
}
