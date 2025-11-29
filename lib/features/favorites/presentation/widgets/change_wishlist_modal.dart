import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/favorites/presentation/widgets/create_wishlist_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/wishlist_snackbar.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';

class ChangeWishlistModal extends ConsumerWidget {
  final String villaId;

  const ChangeWishlistModal({
    super.key,
    required this.villaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final allPropertiesAsync = ref.watch(allPropertiesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Taller modal
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'Save to wishlist',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Content
          Expanded(
            child: userAsync.when(
              data: (user) {
                if (user == null) return const SizedBox();
                final wishlists = user.wishlists;

                return allPropertiesAsync.when(
                  data: (allProperties) {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.8, // Adjust for card height
                      ),
                      itemCount: wishlists.length,
                      itemBuilder: (context, index) {
                        final wishlist = wishlists[index];
                        final isSaved = wishlist.villaIds.contains(villaId);
                        
                        // Find preview image
                        String? previewImageUrl;
                        if (wishlist.villaIds.isNotEmpty) {
                          final firstVillaId = wishlist.villaIds.first;
                          final villa = allProperties.firstWhere(
                              (p) => p.id == firstVillaId,
                              orElse: () => allProperties.first // Fallback?
                              );
                          if (villa.images.isNotEmpty) {
                            previewImageUrl = villa.images.first;
                          }
                        }

                        return GestureDetector(
                          onTap: () async {
                            if (isSaved) {
                              await ref
                                  .read(favoriteRepositoryProvider)
                                  .removeFromWishlist(wishlist.id, villaId);
                            } else {
                              await ref
                                  .read(favoriteRepositoryProvider)
                                  .moveToWishlist(wishlist.id, villaId);
                              if (context.mounted) {
                                context.pop({
                                  'wishlistName': wishlist.name,
                                  'imageUrl': previewImageUrl,
                                });
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSaved 
                                      ? Border.all(color: Colors.black, width: 2)
                                      : Border.all(color: Colors.grey[200]!),
                                    image: previewImageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(previewImageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (previewImageUrl == null)
                                        const Center(
                                          child: Icon(LucideIcons.image, color: Colors.grey, size: 32),
                                        ),
                                      if (isSaved)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, size: 16, color: Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                wishlist.name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${wishlist.villaIds.length} saved',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          // Footer Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateWishlistModal(
                      firstVillaId: villaId,
                    ),
                  );

                  if (result != null && context.mounted) {
                    context.pop(result);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222), // Dark grey/black
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create wishlist',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
