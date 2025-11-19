import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class VillaDetailScreen extends ConsumerWidget {
  final String propertyId;

  const VillaDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need a provider to get a single property.
    // For now, we can use a FutureBuilder with the repository directly or create a provider family.
    // Let's use FutureBuilder for simplicity as we didn't generate a specific provider for single item fetch yet.

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
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(property.name,
                      style: const TextStyle(color: Colors.white, shadows: [
                        Shadow(color: Colors.black45, blurRadius: 5)
                      ])),
                  background: property.images.isNotEmpty
                      ? Image.network(property.images.first, fit: BoxFit.cover)
                      : Container(color: Colors.grey),
                ),
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
                        ),
                        const SizedBox(height: 16),
                        Text(property.description,
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 24),
                        Text('Amenities',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: property.amenities.map((amenity) {
                            return Chip(label: Text(amenity));
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text('Location',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('${property.address}, ${property.city}',
                            style: Theme.of(context).textTheme.bodyLarge),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/booking', extra: property);
                },
                child: const Text('Book Now'),
              ),
            ),
          ),
        );
      },
    );
  }
}
