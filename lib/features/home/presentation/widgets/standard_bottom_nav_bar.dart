import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StandardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StandardBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFE91E63); // Warna Merah/Pink
    final inactiveColor = Colors.grey[600];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Biar gak motong konten atas
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(LucideIcons.search, 'Explore', 0, activeColor, inactiveColor),
              _buildNavItem(LucideIcons.heart, 'Wishlists', 1, activeColor, inactiveColor),
              _buildNavItem(LucideIcons.tent, 'Trips', 2, activeColor, inactiveColor), // Ganti icon sesuai selera
              _buildNavItem(LucideIcons.messageSquare, 'Messages', 3, activeColor, inactiveColor),
              _buildNavItem(LucideIcons.user, 'Profile', 4, activeColor, inactiveColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, Color? inactiveColor) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
