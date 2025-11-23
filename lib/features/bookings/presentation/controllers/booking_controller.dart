import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/bookings/presentation/states/booking_state.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingController extends StateNotifier<BookingState> {
  final Property property;

  BookingController(this.property)
      : super(BookingState(
          checkInDate: DateTime.now().add(const Duration(days: 1)),
          checkOutDate: DateTime.now().add(const Duration(days: 3)),
          guestCount: 1,
          totalPrice: property.pricePerNight * 2, // Default 2 nights
          selectedPaymentMethod: PaymentMethod.qris,
          messageToHost: '',
          currentStep: 0,
        ));

  void updateDates(DateTime start, DateTime end) {
    final nights = end.difference(start).inDays;
    state = state.copyWith(
      checkInDate: start,
      checkOutDate: end,
      totalPrice: property.pricePerNight * nights,
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
