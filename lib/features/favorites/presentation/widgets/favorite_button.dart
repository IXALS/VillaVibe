import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';

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
                // Animate if we are liking it (not unliking)
                if (!isFavorite) {
                  await _controller.forward();
                  await _controller.reverse();
                }

                // Panggil fungsi repository yang kita buat tadi
                await ref
                    .read(favoriteRepositoryProvider)
                    .toggleFavorite(widget.villaId);
                // Karena kita pakai stream di authState, UI akan update otomatis!
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
