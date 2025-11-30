import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';

class HostStats {
  final double monthlyEarnings;
  final double occupancyRate;
  final double overallRating;
  final int totalReviews;
  final int activeListings;
  final int totalStays;
  final bool isSuperhost;

  HostStats({
    required this.monthlyEarnings,
    required this.occupancyRate,
    required this.overallRating,
    required this.totalReviews,
    required this.activeListings,
    required this.totalStays,
    required this.isSuperhost,
  });

  factory HostStats.empty() {
    return HostStats(
      monthlyEarnings: 0,
      occupancyRate: 0,
      overallRating: 0,
      totalReviews: 0,
      activeListings: 0,
      totalStays: 0,
      isSuperhost: false,
    );
  }
}

final hostStatsProvider = StreamProvider.family<HostStats, String>((ref, hostId) {
  final bookingsStream = ref.watch(bookingRepositoryProvider).getHostBookings(hostId);
  final propertiesStream = ref.watch(hostPropertiesProvider(hostId));

  return bookingsStream.asyncMap((bookings) async {
    final properties = await propertiesStream.first;
    return _calculateStats(bookings, properties);
  });
});

HostStats _calculateStats(List<Booking> bookings, List<Property> properties) {
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  // 1. Monthly Earnings
  double monthlyEarnings = 0;
  int bookedNightsInMonth = 0;
  int totalStays = 0;

  for (var booking in bookings) {
    if (booking.status == 'paid' || booking.status == 'completed') {
      // Check if booking falls in current month
      if (booking.startDate.month == currentMonth && booking.startDate.year == currentYear) {
        monthlyEarnings += booking.totalPrice;
        
        // Calculate nights in this month
        final start = booking.startDate;
        final end = booking.endDate;
        final days = end.difference(start).inDays;
        bookedNightsInMonth += days;
      }
      
      if (booking.status == 'completed') {
        totalStays++;
      }
    }
  }

  // 2. Occupancy Rate
  // Simplified: (Booked Nights / (Total Properties * Days in Month)) * 100
  // Note: This assumes all properties were available for the whole month.
  final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
  final totalAvailableNights = properties.length * daysInMonth;
  double occupancyRate = 0;
  if (totalAvailableNights > 0) {
    occupancyRate = (bookedNightsInMonth / totalAvailableNights) * 100;
  }

  // 3. Overall Rating & Reviews
  double totalRatingSum = 0;
  int totalReviews = 0;
  int activeListings = 0;

  for (var property in properties) {
    if (property.reviewsCount > 0) {
      totalRatingSum += property.rating * property.reviewsCount;
      totalReviews += property.reviewsCount;
    }
    if (property.isListed) {
      activeListings++;
    }
  }

  double overallRating = 0;
  if (totalReviews > 0) {
    overallRating = totalRatingSum / totalReviews;
  }

  // 4. Superhost Status (Mock criteria)
  // > 4.8 Rating, > 10 Stays, < 1% Cancellation (ignored for now)
  final isSuperhost = overallRating >= 4.8 && totalStays >= 10;

  return HostStats(
    monthlyEarnings: monthlyEarnings,
    occupancyRate: occupancyRate,
    overallRating: overallRating,
    totalReviews: totalReviews,
    activeListings: activeListings,
    totalStays: totalStays,
    isSuperhost: isSuperhost,
  );
}
