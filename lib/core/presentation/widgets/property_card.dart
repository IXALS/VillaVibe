import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/favorites/presentation/widgets/favorite_button.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final bool showFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                Hero(
                  tag: 'property_image_${property.id}',
                  child: property.images.isNotEmpty
                      ? Image.network(
                          property.images.first,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(LucideIcons.image, size: 48),
                          ),
                        )
                      : Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(LucideIcons.image, size: 48),
                        ),
                ),
                // Favorite heart icon
                if (showFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteButton(
                      villaId: property.id,
                      color: Colors.white,
                    ),
                  ).animate().scale(delay: 200.ms),
              ],
            ),
            
            // Text Content with Padding
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PROPERTY NAME
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 2. PRICE
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      children: [
                        TextSpan(
                          text: 'Rp${property.pricePerNight}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(text: ' per night'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 3. RATING
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        property.rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${property.reviewsCount})', 
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(target: 1)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }
}
