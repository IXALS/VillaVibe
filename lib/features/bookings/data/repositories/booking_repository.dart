import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/booking.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  Future<String> createBooking(Booking booking) async {
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
      messageToHost: booking.messageToHost,
      guestCount: booking.guestCount,
      createdAt: DateTime.now(),
    );
    await docRef.set(newBooking.toMap());
    return docRef.id;
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  Future<void> updateCheckInStatus(String bookingId, bool isCheckedIn) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'isCheckedIn': isCheckedIn,
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  Future<void> completeBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'completed',
    });
  }

  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();
    if (doc.exists) {
      return Booking.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('guestId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      bookings.sort((a, b) => b.startDate.compareTo(a.startDate));
      return bookings;
    });
  }

  Future<List<Booking>> getBookingsForProperty(String propertyId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('propertyId', isEqualTo: propertyId)
        .where('status', isEqualTo: 'paid') // Only count paid bookings
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  Stream<List<Booking>> getHostBookings(String hostId) {
    return _firestore
        .collection('bookings')
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      // Sort by date descending
      bookings.sort((a, b) => b.startDate.compareTo(a.startDate));
      return bookings;
    });
  }

  Stream<List<Booking>> getPropertyBookingsStream(String propertyId) {
    return _firestore
        .collection('bookings')
        .where('propertyId', isEqualTo: propertyId)
        .where('status', whereIn: ['paid', 'completed', 'blocked'])
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      bookings.sort((a, b) => a.startDate.compareTo(b.startDate));
      return bookings;
    });
  }

  Future<void> blockDates(String propertyId, DateTime start, DateTime end) async {
    final docRef = _firestore.collection('bookings').doc();
    final newBooking = Booking(
      id: docRef.id,
      propertyId: propertyId,
      guestId: 'HOST_BLOCK', // Special ID for host blocks
      hostId: '', // Can be empty or current host ID if available
      startDate: start,
      endDate: end,
      totalPrice: 0,
      status: 'blocked',
      messageToHost: 'Blocked by host',
      guestCount: 0,
      createdAt: DateTime.now(),
    );
    await docRef.set(newBooking.toMap());
  }

  Future<void> unblockDates(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
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
  Future<Map<String, dynamic>> validateCheckIn(String bookingId, String hostId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'Booking not found'};
      }

      final booking = Booking.fromFirestore(doc);

      // 1. Host Validation
      if (booking.hostId != hostId) {
        return {'success': false, 'message': 'This booking belongs to another host'};
      }

      // 2. Date Validation (Strictly Today)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);

      if (!bookingStart.isAtSameMomentAs(today)) {
        if (bookingStart.isAfter(today)) {
          return {'success': false, 'message': 'Too early! Check-in is on ${bookingStart.toString().split(' ')[0]}'};
        } else {
          // Optional: Allow late check-in if still within booking period?
          // For now, strict check-in day as requested.
          // Actually, if it's during the stay, maybe allow? 
          // User said "real date", usually check-in is on start date.
          // Let's stick to strict start date for "Check In".
          return {'success': false, 'message': 'Booking expired. Check-in was on ${bookingStart.toString().split(' ')[0]}'};
        }
      }

      // 3. Status Validation
      if (booking.status == 'cancelled') {
        return {'success': false, 'message': 'Booking was cancelled'};
      }
      
      // 4. Already Checked In
      if (booking.isCheckedIn) {
        return {'success': false, 'message': 'Guest already checked in'};
      }
      
      if (booking.status != 'paid' && booking.status != 'confirmed') {
         return {'success': false, 'message': 'Booking not confirmed (Status: ${booking.status})'};
      }

      // Success: Update Status
      await updateCheckInStatus(bookingId, true);
      // Also update status to 'checked_in' if that's a valid status flow, 
      // but 'isCheckedIn' flag is safer for now.
      
      return {'success': true, 'booking': booking};
      
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  return BookingRepository(FirebaseFirestore.instance);
}
