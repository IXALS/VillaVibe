import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/create_wishlist_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/change_wishlist_modal.dart';
import 'package:villavibe/features/favorites/presentation/widgets/wishlist_snackbar.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String villaId;
  final Color
      color; // Supaya bisa dipakai di Card (Putih) atau Detail (Hitam/Merah)

  const FavoriteButton({
    super.key,
    required this.villaId,
    this.color = Colors.white,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final isFavorite = user?.savedVillas.contains(widget.villaId) ?? false;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : widget.color,
            ),
            onPressed: () async {
              if (user == null) {
                showLoginModal(context); // Kalau belum login, suruh login
              } else {
                // Debug print to check wishlists state
                print('User wishlists count: ${user.wishlists.length}');
                
                if (user.wishlists.isEmpty) {
                  print('Showing CreateWishlistModal');
                  // Case 1: No wishlists -> Show Create Modal
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateWishlistModal(
                      firstVillaId: widget.villaId,
                    ),
                  );
                  
                  if (result is Map<String, dynamic> && context.mounted) {
                     showWishlistSnackBar(
                      context,
                      wishlistName: result['wishlistName'],
                      imageUrl: result['imageUrl'],
                      onChange: () {
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ChangeWishlistModal(
                              villaId: widget.villaId,
                            ),
                          );
                        }
                      },
                    );
                  }
                  // If successful, repository handles the update and UI reflects it
                } else {
                  // Case 2: Has wishlists
                  if (isFavorite) {
                    // If already favorite -> Toggle (Remove)
                    // Animate
                    await _controller.forward();
                    await _controller.reverse();
                    
                    await ref
                        .read(favoriteRepositoryProvider)
                        .toggleFavorite(widget.villaId);
                  } else {
                    // If NOT favorite -> Show Change Modal (to choose where to save)
                    // Do NOT auto-save.
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ChangeWishlistModal(
                        villaId: widget.villaId,
                      ),
                    );

                    if (result is Map<String, dynamic> && context.mounted) {
                       showWishlistSnackBar(
                        context,
                        wishlistName: result['wishlistName'],
                        imageUrl: result['imageUrl'],
                        onChange: () {
                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ChangeWishlistModal(
                                villaId: widget.villaId,
                              ),
                            );
                          }
                        },
                      );
                    }
                  }
                }
              }
            },
          ),
        );
      },
      loading: () => const SizedBox(width: 24, height: 24), // Hide saat loading
      error: (_, __) => const Icon(LucideIcons.heartOff),
    );
  }
}
