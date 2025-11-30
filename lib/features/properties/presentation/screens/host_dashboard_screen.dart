import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/property_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

import '../../../../core/presentation/widgets/property_card_shimmer.dart';
import 'package:villavibe/features/host/presentation/screens/mode_transition_screen.dart';

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ModeTransitionScreen(targetIsHost: false),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            icon: Icon(Icons.person,
                color: Theme.of(context).colorScheme.primary),
            label: Text('Guest Mode',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-property'),
        label: const Text('Add Property'),
        icon: const Icon(Icons.add),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));

          final propertiesAsync = ref.watch(hostPropertiesProvider(user.uid));

          return propertiesAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.house_siding,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No properties listed yet.'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/add-property'),
                        child: const Text('List your first villa'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (property.images.isNotEmpty)
                          Image.network(
                            property.images.first,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                                child: Icon(Icons.image, size: 48)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${property.city} • \$${property.pricePerNight}/night',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(property.rating.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const PropertyCardShimmer(),
            ),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading user: $e')),
      ),
    );
  }
}
