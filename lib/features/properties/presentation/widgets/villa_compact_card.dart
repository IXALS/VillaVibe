import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_modal.dart';
import 'package:villavibe/features/favorites/data/repositories/favorite_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class VillaCompactCard extends ConsumerStatefulWidget {
  final Property property;
  final VoidCallback? onTap;

  const VillaCompactCard({
    super.key,
    required this.property,
    this.onTap,
    this.heroTagPrefix,
  });

  final String? heroTagPrefix;

  @override
  ConsumerState<VillaCompactCard> createState() => _VillaCompactCardState();
}

class _VillaCompactCardState extends ConsumerState<VillaCompactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final isFavorite = user?.savedVillas.contains(widget.property.id) ?? false;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0, // Square 1:1
                    child: Hero(
                      tag: '${widget.heroTagPrefix ?? ''}villa_img_${widget.property.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.property.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.property.images.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(LucideIcons.image,
                                    color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  // Heart Icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (user == null) {
                          showLoginModal(context);
                        } else {
                          ref
                              .read(favoriteRepositoryProvider)
                              .toggleFavorite(widget.property.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : LucideIcons.heart,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20, // Slightly smaller to fit in circle
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content Section
              Text(
                '${widget.property.name} / ${widget.property.city}',
                maxLines: 2, // Allow 2 lines as per reference
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.2, // Tighter line height for 2 lines
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${currencyFormat.format(widget.property.pricePerNight)} / night',
                      maxLines: 2,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.star, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    widget.property.rating.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
