import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/bookings/presentation/states/booking_state.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart'; // Added this import
import 'package:villavibe/features/properties/domain/services/price_service.dart';

class BookingController extends StateNotifier<BookingState> {
  final Property property;

  BookingController(this.property)
      : super(BookingState(
          checkInDate: DateTime.now().add(const Duration(days: 1)),
          checkOutDate: DateTime.now().add(const Duration(days: 3)),
          guestCount: 1,
          totalPrice: PriceService.calculateTotalPrice(
            property,
            DateTime.now().add(const Duration(days: 1)),
            DateTime.now().add(const Duration(days: 3)),
          ),
          selectedPaymentMethod: PaymentMethod.qris,
          messageToHost: '',
          currentStep: 0,
        ));

  void updateDates(DateTime start, DateTime end) {
    state = state.copyWith(
      checkInDate: start,
      checkOutDate: end,
      totalPrice: PriceService.calculateTotalPrice(property, start, end),
    );
  }



  void updateGuests(int count) {
    state = state.copyWith(guestCount: count);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setMessage(String message) {
    state = state.copyWith(messageToHost: message);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void resumeBooking(Booking booking) {
    state = state.copyWith(
      checkInDate: booking.startDate,
      checkOutDate: booking.endDate,
      totalPrice: booking.totalPrice,
      messageToHost: booking.messageToHost,
      currentStep: 4, // Jump to QRIS step
    );
  }
}

final bookingControllerProvider = StateNotifierProvider.family
    .autoDispose<BookingController, BookingState, Property>((ref, property) {
  return BookingController(property);
});

final propertyBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, propertyId) {
  return ref.watch(bookingRepositoryProvider).getPropertyBookingsStream(propertyId);
});

final bookingStreamProvider = StreamProvider.family<Booking?, String>((ref, bookingId) {
  return ref.watch(bookingRepositoryProvider).streamBooking(bookingId);
});
