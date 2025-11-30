import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/domain/models/app_user.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class HostDashboardData {
  final Booking? nextBooking;
  final AppUser? nextGuest;
  final Property? nextProperty;
  final List<Booking> checkIns;
  final List<Booking> checkOuts;
  final List<Booking> currentlyHosting;
  final int updatesCount;
  final double monthlyEarnings;
  final double? previousMonthEarnings;
  final double? earningsChangePercentage;
  final Map<String, double>? earningsByProperty;
  final Map<String, Property> propertyMap;

  HostDashboardData({
    this.nextBooking,
    this.nextGuest,
    this.nextProperty,
    required this.checkIns,
    required this.checkOuts,
    required this.currentlyHosting,
    required this.updatesCount,
    required this.monthlyEarnings,
    this.previousMonthEarnings,
    this.earningsChangePercentage,
    this.earningsByProperty,
    required this.propertyMap,
  });

  factory HostDashboardData.empty() {
    return HostDashboardData(
      checkIns: [],
      checkOuts: [],
      currentlyHosting: [],
      updatesCount: 0,
      monthlyEarnings: 0.0,
      previousMonthEarnings: 0.0,
      earningsChangePercentage: 0.0,
      earningsByProperty: {},
      propertyMap: {},
    );
  }
}

final hostDashboardProvider = StreamProvider.family<HostDashboardData, String>((ref, hostId) {
  final bookingsStream = ref.watch(bookingRepositoryProvider).getHostBookings(hostId);
  final propertiesAsync = ref.watch(hostPropertiesProvider(hostId));

  return bookingsStream.asyncMap((bookings) async {
    final properties = propertiesAsync.valueOrNull ?? [];
    return _processDashboardData(ref, bookings, properties);
  });
});

Future<HostDashboardData> _processDashboardData(
  Ref ref,
  List<Booking> bookings,
  List<Property> properties,
) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Create Property Map for easy lookup
  final propertyMap = {for (var p in properties) p.id: p};

  List<Booking> checkIns = [];
  List<Booking> checkOuts = [];
  List<Booking> currentlyHosting = [];
  Booking? nextBooking;

  // Helper to get property by ID
  Property? getProperty(String id) {
    return propertyMap[id];
  }

  double monthlyEarnings = 0.0;
  double previousMonthEarnings = 0.0;
  Map<String, double> earningsByProperty = {};

  final currentMonth = now.month;
  final currentYear = now.year;
  
  final previousMonthDate = DateTime(now.year, now.month - 1);
  final previousMonth = previousMonthDate.month;
  final previousYear = previousMonthDate.year;

  for (var booking in bookings) {
    if (booking.status == 'cancelled' || booking.status == 'pending') continue;

    // Calculate Earnings
    if (booking.status == 'paid' || booking.status == 'completed') {
      // Current Month
      if (booking.startDate.month == currentMonth && booking.startDate.year == currentYear) {
        final amount = booking.totalPrice.toDouble();
        monthlyEarnings += amount;
        earningsByProperty[booking.propertyId] = (earningsByProperty[booking.propertyId] ?? 0) + amount;
      }
      // Previous Month
      else if (booking.startDate.month == previousMonth && booking.startDate.year == previousYear) {
        previousMonthEarnings += booking.totalPrice.toDouble();
      }
    }

    final start = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
    final end = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);

    // Check-ins Today (Only if not checked in yet)
    if (start.isAtSameMomentAs(today) && !booking.isCheckedIn) {
      checkIns.add(booking);
    }

    // Check-outs Today
    if (end.isAtSameMomentAs(today)) {
      checkOuts.add(booking);
    }

    // Currently Hosting
    // 1. Started before today, ends after today
    // 2. OR Started today AND is already checked in
    // AND status is NOT completed
    if (((start.isBefore(today) && end.isAfter(today)) || 
        (start.isAtSameMomentAs(today) && booking.isCheckedIn)) &&
        booking.status != 'completed') {
      currentlyHosting.add(booking);
    }

    // Find Next Booking (Starts tomorrow or later)
    if (start.isAfter(today)) {
      if (nextBooking == null || start.isBefore(nextBooking.startDate)) {
        nextBooking = booking;
      }
    }
  }

  // Calculate Percentage Change
  double earningsChangePercentage = 0.0;
  if (previousMonthEarnings > 0) {
    earningsChangePercentage = ((monthlyEarnings - previousMonthEarnings) / previousMonthEarnings) * 100;
  } else if (monthlyEarnings > 0) {
    earningsChangePercentage = 100.0; // 100% increase if previous was 0
  }

  // Fetch details for Next Booking
  AppUser? nextGuest;
  Property? nextProperty;

  if (nextBooking != null) {
    nextGuest = await ref.read(authRepositoryProvider).getUserById(nextBooking.guestId);
    nextProperty = getProperty(nextBooking.propertyId);
  } else if (checkIns.isNotEmpty) {
    // Fallback: If no future booking, show the first check-in of today as "Up Next" (if not checked in yet)
    nextBooking = checkIns.first;
    nextGuest = await ref.read(authRepositoryProvider).getUserById(nextBooking.guestId);
    nextProperty = getProperty(nextBooking.propertyId);
  }

  final updatesCount = checkIns.length + checkOuts.length;

  return HostDashboardData(
    nextBooking: nextBooking,
    nextGuest: nextGuest,
    nextProperty: nextProperty,
    checkIns: checkIns,
    checkOuts: checkOuts,
    currentlyHosting: currentlyHosting,
    updatesCount: updatesCount,
    monthlyEarnings: monthlyEarnings,
    previousMonthEarnings: previousMonthEarnings,
    earningsChangePercentage: earningsChangePercentage,
    earningsByProperty: earningsByProperty,
    propertyMap: propertyMap,
  );
}
