import 'package:flutter/foundation.dart';

enum PaymentMethod { creditCard, qris }

@immutable
class BookingState {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final int totalPrice;
  final PaymentMethod selectedPaymentMethod;
  final String messageToHost;
  final int currentStep;

  const BookingState({
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.totalPrice,
    required this.selectedPaymentMethod,
    required this.messageToHost,
    required this.currentStep,
  });

  BookingState copyWith({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestCount,
    int? totalPrice,
    PaymentMethod? selectedPaymentMethod,
    String? messageToHost,
    int? currentStep,
  }) {
    return BookingState(
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guestCount: guestCount ?? this.guestCount,
      totalPrice: totalPrice ?? this.totalPrice,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      messageToHost: messageToHost ?? this.messageToHost,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  int get nights => checkOutDate.difference(checkInDate).inDays;
}
