import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:villavibe/core/presentation/widgets/property_card.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class DestinationDetailScreen extends ConsumerWidget {
  final String destinationName;
  final String imageUrl;

  const DestinationDetailScreen({
    super.key,
    required this.destinationName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil semua data properti
    final allPropertiesAsync = ref.watch(allPropertiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: allPropertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allProperties) {
          // LOGIC FILTER: Ambil villa yang kotanya mengandung nama destinasi
          final filteredProperties = allProperties.where((property) {
            // Asumsi di model Property ada field 'city' atau 'address'
            // Kita pakai .contains biar fleksibel (misal: "Batu, Malang" kena dua-duanya)
            return property.city.toLowerCase().contains(destinationName.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Header Gambar Besar (Hero)
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  centerTitle: false,
                  title: Text(
                    destinationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 8.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                      ),
                      // Gradient gelap di bawah biar tulisan terbaca
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Judul Kecil & Jumlah Properti
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${filteredProperties.length} places to stay",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Explore the best villas in $destinationName",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Daftar Villa (List)
              filteredProperties.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(LucideIcons.home, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                "No villas found in $destinationName yet.",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = filteredProperties[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: PropertyCard(
                                property: property,
                                onTap: () {
                                  // Ke detail villa seperti biasa
                                  context.push('/property/${property.id}', extra: property);
                                },
                              ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0),
                            );
                          },
                          childCount: filteredProperties.length,
                        ),
                      ),
                    ),
                
              // Padding bawah biar ga mentok
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}
