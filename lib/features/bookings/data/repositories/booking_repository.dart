import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/booking.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  Future<void> createBooking(Booking booking) async {
    final docRef = _firestore.collection('bookings').doc();
    final newBooking = Booking(
      id: docRef.id,
      propertyId: booking.propertyId,
      guestId: booking.guestId,
      hostId: booking.hostId,
      startDate: booking.startDate,
      endDate: booking.endDate,
      totalPrice: booking.totalPrice,
      status: booking.status,
    );
    await docRef.set(newBooking.toMap());
  }

  Future<List<Booking>> getBookingsForProperty(String propertyId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('propertyId', isEqualTo: propertyId)
        .where('status', isEqualTo: 'paid') // Only count paid bookings
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  Future<bool> isPropertyAvailable(
      String propertyId, DateTime start, DateTime end) async {
    // This is a simplified client-side check.
    // Ideally, this should be done via a Cloud Function or Transaction to prevent race conditions.
    final bookings = await getBookingsForProperty(propertyId);

    for (var booking in bookings) {
      // Check for overlap
      // Overlap exists if (StartA <= EndB) and (EndA >= StartB)
      if (start.isBefore(booking.endDate) && end.isAfter(booking.startDate)) {
        return false;
      }
    }
    return true;
  }
}

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  return BookingRepository(FirebaseFirestore.instance);
}
