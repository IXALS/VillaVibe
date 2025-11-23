import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/states/booking_state.dart';
import 'package:villavibe/features/bookings/presentation/widgets/booking_progress_bar.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class RequestToBookScreen extends ConsumerWidget {
  final Property property;

  const RequestToBookScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(property));
    final controller = ref.read(bookingControllerProvider(property).notifier);
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            controller.previousStep();
            context.pop();
          },
        ),
        title: const Text(
          'Request to book',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(property, bookingState, currencyFormat),
                  const SizedBox(height: 32),
                  _buildPaymentMethodSection(bookingState),
                  const SizedBox(height: 32),
                  _buildPriceDetails(bookingState, property, currencyFormat),
                  const SizedBox(height: 32),
                  _buildCancellationPolicy(),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, ref, controller, bookingState),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      Property property, BookingState state, NumberFormat format) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            property.images.first,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMM d').format(state.checkInDate)} – ${DateFormat('d, yyyy').format(state.checkOutDate)}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                format.format(state.totalPrice),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment method',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              state.selectedPaymentMethod == PaymentMethod.creditCard
                  ? LucideIcons.creditCard
                  : LucideIcons.qrCode,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              state.selectedPaymentMethod == PaymentMethod.creditCard
                  ? 'Credit or debit card'
                  : 'GoPay (QRIS)',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Ideally navigate back to payment step or show modal
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetails(
      BookingState state, Property property, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                '${state.nights} nights x ${format.format(property.pricePerNight)}'),
            Text(format.format(state.totalPrice)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total (IDR)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              format.format(state.totalPrice),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cancellation policy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            children: [
              TextSpan(
                text: 'Free cancellation before check-in. ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    'Cancel before check-in for a full refund. After that, the reservation is non-refundable.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref,
      BookingController controller, BookingState bookingState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookingProgressBar(currentStep: 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLoadingOverlay(context, ref, controller, bookingState);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Request to book',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingOverlay(BuildContext context, WidgetRef ref,
      BookingController controller, BookingState bookingState) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Creating booking...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Create pending booking
      final user = ref.read(currentUserProvider).value!;
      final booking = Booking(
        id: '', // Repo handles ID
        propertyId: property.id,
        guestId: user.uid,
        hostId: property.hostId,
        startDate: bookingState.checkInDate,
        endDate: bookingState.checkOutDate,
        totalPrice: bookingState.totalPrice,
        status: Booking.statusPending,
        messageToHost: bookingState.messageToHost,
        createdAt: DateTime.now(),
      );

      final bookingId =
          await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close overlay
        controller.nextStep();
        context.push('/booking/qris', extra: {
          'property': property,
          'bookingId': bookingId,
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: $e')),
        );
      }
    }
  }
}
