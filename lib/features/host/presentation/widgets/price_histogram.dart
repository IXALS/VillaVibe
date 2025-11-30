import 'dart:math';
import 'package:flutter/material.dart';

class PriceHistogram extends StatelessWidget {
  final double currentPrice;
  final double minPrice;
  final double maxPrice;

  const PriceHistogram({
    super.key,
    required this.currentPrice,
    required this.minPrice,
    required this.maxPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Generate some fake distribution data
    final random = Random(42); // Fixed seed for consistency
    final bars = List.generate(30, (index) {
      // Create a bell curve-ish shape
      final x = index / 30;
      final height = exp(-pow((x - 0.4), 2) / 0.05) * 0.8 + random.nextDouble() * 0.2;
      return height;
    });

    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.asMap().entries.map((entry) {
          final index = entry.key;
          final heightPct = entry.value;
          
          // Calculate price range for this bar using Logarithmic scale
          // to match the slider's behavior
          final t = index / 29;
          final barPrice = minPrice * pow(maxPrice / minPrice, t);
          final isActive = barPrice <= currentPrice;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 60 * heightPct,
                decoration: BoxDecoration(
                  color: isActive ? Colors.black87 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
