import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/core/presentation/widgets/property_card.dart';
import 'package:villavibe/features/favorites/presentation/providers/favorites_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritePropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlists',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.heart, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start exploring and save your favorite villas!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PropertyCard(
                  property: property,
                  onTap: () {
                    context.push('/property/${property.id}', extra: property);
                  },
                ),
              )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
