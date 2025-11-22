import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // Index kategori yang lagi dipilih (0 = All)
  int _selectedIndex = 0;

  // Data Kategori (Icon + Nama)
  final List<Map<String, dynamic>> _categories = [
    {'icon': LucideIcons.layoutGrid, 'label': 'All'},
    {'icon': LucideIcons.waves, 'label': 'Beach'},
    {'icon': LucideIcons.mountain, 'label': 'Mountain'},
    {'icon': LucideIcons.building2, 'label': 'City'},
    {'icon': LucideIcons.tent, 'label': 'Camping'},
    {'icon': LucideIcons.snowflake, 'label': 'Arctic'},
    {'icon': LucideIcons.palmtree, 'label': 'Tropical'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // Tinggi area scroll
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24), // Padding kiri-kanan layar
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12), // Jarak antar tombol
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              // Nanti di sini kita tambahkan logic filter villa
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20), // Rounded pill shape
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['label'] as String,
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