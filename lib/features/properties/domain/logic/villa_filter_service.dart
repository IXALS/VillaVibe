import 'package:flutter/material.dart';

/// A standalone service class for filtering villas.
class VillaFilterService {
  /// Filters a list of [Villa]s based on the provided [VillaFilter].
  ///
  /// Returns a new list containing only the villas that match all criteria.
  static List<Villa> filterVillas(List<Villa> villas, VillaFilter filter) {
    return villas.where((villa) {
      // 1. Search Query Check
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchesName = villa.name.toLowerCase().contains(query);
        final matchesLocation =
            villa.locationName.toLowerCase().contains(query);

        if (!matchesName && !matchesLocation) {
          return false;
        }
      }

      // 2. Price Range Check
      if (filter.priceRange != null) {
        if (villa.pricePerNight < filter.priceRange!.start ||
            villa.pricePerNight > filter.priceRange!.end) {
          return false;
        }
      }

      // 3. Map Bounds Check (Geospatial)
      if (filter.mapBounds != null) {
        // Check if the villa's coordinates are within the bounds.
        // A LatLngBounds is defined by its southwest and northeast corners.
        // Latitude must be between southwest.latitude and northeast.latitude.
        // Longitude must be between southwest.longitude and northeast.longitude.
        // Note: This simple check assumes the bounds do not cross the antimeridian (180th meridian).
        // If they do, the longitude check logic would need to be slightly different.

        final bounds = filter.mapBounds!;
        final bool latInRange = villa.latitude >= bounds.southWest.latitude &&
            villa.latitude <= bounds.northEast.latitude;

        final bool lngInRange = villa.longitude >= bounds.southWest.longitude &&
            villa.longitude <= bounds.northEast.longitude;

        if (!latInRange || !lngInRange) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

// --- Data Models ---

/// Represents a Villa with essential details for filtering.
class Villa {
  final String id;
  final String name;
  final String locationName;
  final int pricePerNight;
  final double latitude;
  final double longitude;

  const Villa({
    required this.id,
    required this.name,
    required this.locationName,
    required this.pricePerNight,
    required this.latitude,
    required this.longitude,
  });
}

/// Holds filter parameters for the villa search.
class VillaFilter {
  /// Keywords to match against name or location. Case-insensitive.
  final String? searchQuery;

  /// Min and max price range per night.
  final RangeValues? priceRange;

  /// The visible area of the map to restrict results to.
  final LatLngBounds? mapBounds;

  const VillaFilter({
    this.searchQuery,
    this.priceRange,
    this.mapBounds,
  });
}

/// A simple representation of Map Bounds (SouthWest and NorthEast).
/// In a real app, this might come from google_maps_flutter or similar package.
class LatLngBounds {
  final LatLng southWest;
  final LatLng northEast;

  const LatLngBounds({
    required this.southWest,
    required this.northEast,
  });
}

/// A simple representation of Latitude and Longitude.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
