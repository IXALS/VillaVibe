import '../models/property.dart';

class PriceService {
  /// Calculates the total price for a stay, considering custom daily prices.
  static int calculateTotalPrice(Property property, DateTime start, DateTime end) {
    if (start.isAfter(end)) return 0;
    
    int total = 0;
    DateTime date = start;
    
    // Iterate until end date (exclusive)
    while (date.isBefore(end)) {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final price = property.customPrices[dateStr] ?? property.pricePerNight;
      total += price;
      date = date.add(const Duration(days: 1));
    }
    
    return total;
  }

  /// Calculates the average nightly price for a stay.
  /// Returns base price if dates are invalid or same day.
  static int calculateAverageNightlyPrice(Property property, DateTime? start, DateTime? end) {
    if (start == null || end == null || start.isAfter(end) || start.isAtSameMomentAs(end)) {
      return property.pricePerNight;
    }

    final total = calculateTotalPrice(property, start, end);
    final nights = end.difference(start).inDays;
    
    if (nights == 0) return property.pricePerNight;
    
    return (total / nights).round();
  }

  /// Returns the lowest price found in custom prices or the base price.
  /// Useful for "From $X" display.
  static int getLowestPrice(Property property) {
    if (property.customPrices.isEmpty) {
      return property.pricePerNight;
    }
    
    int minPrice = property.pricePerNight;
    for (final price in property.customPrices.values) {
      if (price < minPrice) {
        minPrice = price;
      }
    }
    return minPrice;
  }
}
