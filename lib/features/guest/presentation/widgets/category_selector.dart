import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/category.dart';

class CategorySelector extends StatefulWidget {
  final List<Category> categories;
  final Function(Category category) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = _selectedIndex == index;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onCategoryChanged(category);
              },
              // ✨ MAGISNYA DI SINI: AnimatedContainer ✨
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic, // Kurva animasi biar 'membal' dikit
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(30), // Lebih bulat (Pill shape modern)
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    // Icon juga dianimasikan warnanya
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Nunito', // Opsional kalau pakai font custom
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            size: 18,
                            color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
                          ),
                          const SizedBox(width: 8),
                          Text(category.label),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}