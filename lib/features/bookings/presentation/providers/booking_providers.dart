import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';

final userBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(bookingRepositoryProvider).getUserBookings(user.uid);
});
