import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

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
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                Hero(
                  tag: 'property_image_${property.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first,
                            height: 260,
                            width: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 260,
                              width: 280,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 48),
                            ),
                          )
                        : Container(
                            height: 260,
                            width: 280,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 48),
                          ),
                  ),
                ),
                // Favorite heart icon
                if (showFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.favorite_border,
                      size: 24,
                      color: Colors.white,
                    ),
                  ).animate().scale(delay: 200.ms),
              ],
            ),
            const SizedBox(height: 12),
            // Property details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      property.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text: 'Rp${property.pricePerNight}', // Currency format
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(text: ' for 2 nights'), // Match reference
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
