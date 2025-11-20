import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.search,
                label: 'Explore',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite_border,
                label: 'Wishlists',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.near_me_outlined, // Airbnb logo proxy
                label: 'Trips',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
                index: 3,
              ),
              _buildNavItem(
                context,
                icon: Icons.account_circle_outlined,
                label: 'Log in',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600];

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? _getFilledIcon(icon) : icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    if (icon == Icons.search) return Icons.search;
    if (icon == Icons.favorite_border) return Icons.favorite;
    if (icon == Icons.card_travel) return Icons.card_travel;
    if (icon == Icons.message_outlined) return Icons.message;
    if (icon == Icons.account_circle_outlined) return Icons.account_circle;
    return icon;
  }
}
