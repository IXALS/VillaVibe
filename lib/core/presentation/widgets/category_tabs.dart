import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Homes', 'icon': Icons.home_outlined},
    {'name': 'Beaches', 'icon': Icons.beach_access_outlined, 'isNew': true},
    {'name': 'Mountain', 'icon': Icons.landscape_outlined, 'isNew': true},
    {'name': 'City', 'icon': Icons.location_city_outlined, 'isNew': true},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category['name'] == selectedCategory;
          final isNew = category['isNew'] ?? false;

          return GestureDetector(
            onTap: () => onCategorySelected(category['name']),
            child: Container(
              margin: const EdgeInsets.only(right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        category['icon'],
                        size: 32,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                      if (isNew)
                        Positioned(
                          top: -2,
                          right: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFF3B5998), // Facebook/Navy blue color for NEW badge
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    Container(
                      height: 2,
                      width: 40,
                      color: Colors.black,
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
