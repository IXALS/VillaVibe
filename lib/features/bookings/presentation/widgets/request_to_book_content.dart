import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/states/booking_state.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class RequestToBookContent extends ConsumerWidget {
  final Property property;

  const RequestToBookContent({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(property));
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return SingleChildScrollView(
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
}
