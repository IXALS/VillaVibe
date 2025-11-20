import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';

class VillaDetailScreen extends ConsumerWidget {
  final String propertyId;

  const VillaDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current user state to keep the provider alive and update UI
    final userAsync = ref.watch(currentUserProvider);

    return FutureBuilder<Property?>(
      future: ref.read(propertyRepositoryProvider).getProperty(propertyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final property = snapshot.data;
        if (property == null) {
          return const Scaffold(
              body: Center(child: Text('Property not found')));
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'property_image_${property.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        property.images.isNotEmpty
                            ? Image.network(
                                property.images.first,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey[300]),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {},
                    ),
                  ).animate().scale(
                      delay: 100.ms,
                      duration: 300.ms,
                      curve: Curves.easeOutBack),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.black),
                      onPressed: () {},
                    ),
                  ).animate().scale(
                      delay: 200.ms,
                      duration: 300.ms,
                      curve: Curves.easeOutBack),
                  const SizedBox(width: 16),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${property.pricePerNight} / night',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                Text(property.rating.toString(),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 16),
                        Text(property.description,
                                style: Theme.of(context).textTheme.bodyLarge)
                            .animate()
                            .fadeIn(delay: 400.ms),
                        const SizedBox(height: 24),
                        Text('Amenities',
                                style: Theme.of(context).textTheme.titleLarge)
                            .animate()
                            .fadeIn(delay: 500.ms),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: property.amenities.map((amenity) {
                            return Chip(label: Text(amenity));
                          }).toList(),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 24),
                        Text('Location',
                                style: Theme.of(context).textTheme.titleLarge)
                            .animate()
                            .fadeIn(delay: 700.ms),
                        const SizedBox(height: 8),
                        Text('${property.address}, ${property.city}',
                                style: Theme.of(context).textTheme.bodyLarge)
                            .animate()
                            .fadeIn(delay: 800.ms),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  final user = userAsync.value;
                  if (user == null) {
                    LoginModal.show(context);
                  } else {
                    context.push('/booking', extra: property);
                  }
                },
                child: const Text('Book Now'),
              ),
            ),
          ).animate().slideY(
              begin: 1, end: 0, delay: 900.ms, curve: Curves.easeOutQuad),
        );
      },
    );
  }
}
