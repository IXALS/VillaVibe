import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/models/category.dart';

class CategorySelector extends StatefulWidget {
  final Function(String category) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.onCategoryChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;

  final List<Category> _categories = const [
    Category(icon: LucideIcons.layoutGrid, label: 'All'),
    Category(icon: LucideIcons.waves, label: 'Beach'),
    Category(icon: LucideIcons.mountain, label: 'Mountain'),
    Category(icon: LucideIcons.building2, label: 'City'),
    Category(icon: LucideIcons.tent, label: 'Camping'),
    // Arctic removed
    Category(icon: LucideIcons.palmtree, label: 'Tropical'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onCategoryChanged(category.label);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}