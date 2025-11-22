import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/domain/models/app_user.dart';
import 'package:villavibe/features/home/presentation/widgets/home_search_container.dart';

class HomeHeroSection extends StatelessWidget {
  final VoidCallback onSearchTap;
  final AppUser? user;

  const HomeHeroSection({
    super.key,
    required this.onSearchTap,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Slightly reduced height
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            bottom:
                40, // Leave space for the curve/overlap if needed, or just fill
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=2070&auto=format&fit=crop', // Luxury cabin/hotel
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[300]),
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            bottom: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            top: 40, // Moved up from 60
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Norway',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30), // Reduced spacing

                // Greeting
                Text(
                  user != null
                      ? 'Hey, ${user!.displayName.split(' ').first}!\nTell us where you want to go'
                      : 'Hey,\nTell us where you want to go',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 30), // Reduced spacing

                // Search Container
                HomeSearchContainer(onTap: onSearchTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
