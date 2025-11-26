import 'package:flutter/material.dart';

/// Constants for search filter functionality
class SearchConstants {
  SearchConstants._(); // Private constructor to prevent instantiation

  /// Minimum price for property search filter
  static const double minPrice = 0;

  /// Maximum price for property search filter
  static const double maxPrice = 50000000;

  /// Default price range for search filter
  static const RangeValues defaultPriceRange = RangeValues(minPrice, maxPrice);
}
