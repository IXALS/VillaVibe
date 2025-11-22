import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';

class FavoriteButton extends ConsumerWidget {
  final String villaId;
  final Color
      color; // Supaya bisa dipakai di Card (Putih) atau Detail (Hitam/Merah)

  const FavoriteButton({
    super.key,
    required this.villaId,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final isFavorite = user?.savedVillas.contains(villaId) ?? false;

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : color,
          ),
          onPressed: () async {
            if (user == null) {
              showLoginModal(context); // Kalau belum login, suruh login
            } else {
              // Panggil fungsi repository yang kita buat tadi
              await ref
                  .read(favoriteRepositoryProvider)
                  .toggleFavorite(villaId);
              // Karena kita pakai stream di authState, UI akan update otomatis!
            }
          },
        );
      },
      loading: () => const SizedBox(width: 24, height: 24), // Hide saat loading
      error: (_, __) => const Icon(LucideIcons.heartOff),
    );
  }
}
