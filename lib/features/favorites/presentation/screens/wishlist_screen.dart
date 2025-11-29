import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/favorites/presentation/screens/wishlist_detail_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final allPropertiesAsync = ref.watch(allPropertiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Wishlists',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.wishlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.heart, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No wishlists yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first wishlist to start saving!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            );
          }

          return allPropertiesAsync.when(
            data: (allProperties) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.8,
                ),
                itemCount: user.wishlists.length,
                itemBuilder: (context, index) {
                  final wishlist = user.wishlists[index];
                  // Find first villa for preview image
                  String? previewImageUrl;
                  if (wishlist.villaIds.isNotEmpty) {
                    final firstVilla = allProperties.firstWhere(
                      (p) => p.id == wishlist.villaIds.first,
                      orElse: () => allProperties.first, // Fallback
                    );
                    // Assuming Property has imageUrls or similar
                    if (firstVilla.images.isNotEmpty) {
                      previewImageUrl = firstVilla.images.first;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WishlistDetailScreen(
                            wishlist: wishlist,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        // Hero Background
                        Positioned.fill(
                          child: Hero(
                            tag: 'wishlist_${wishlist.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: previewImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(previewImageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  if (previewImageUrl == null)
                                    const Center(
                                      child: Icon(LucideIcons.image,
                                          color: Colors.grey, size: 32),
                                    ),
                                  // Gradient Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.0),
                                          Colors.black.withValues(alpha: 0.2),
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                        stops: const [0.0, 0.4, 0.7, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text Content (Not Hero)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'wishlist_title_${wishlist.id}',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    wishlist.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.white,
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${wishlist.villaIds.length} saved',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms, delay: (50 * index + 100).ms).slideY(begin: 0.2, end: 0),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (50 * index).ms)
                      .slideY(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
